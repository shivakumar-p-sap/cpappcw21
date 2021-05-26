/**
 * Implementation for Risk Management service defined in ./risk-service.cds
 */
module.exports = async (srv) => {
    srv.after('READ', 'Risks', each => {
        if (each.impact >= 100000) {
        each.criticality = 1;
        } else {
        each.criticality = 2;
        }
        });

        srv.on('READ', 'Risks', async (req, next) => {
            const expandIndex = req.query.SELECT.columns.findIndex(({ expand, ref }) => expand && ref[0] === 'bp');
            if (expandIndex < 0) return next();
            req.query.SELECT.columns.splice(expandIndex, 1);
            if (!req.query.SELECT.columns.find( column => column.ref.find( ref => ref == "bp_ID" ))) req.query.SELECT.columns.push({ ref: ["bp_ID"] });
            var data = await next();
            // Request all Business Partners
            const risks = Array.isArray(data) ? data:[data]
            // Request all Business Partners
            const mock = !cds.env.requires.API_BUSINESS_PARTNER.credentials;
            const tx = mock ? BupaService.tx(req) : BupaService;
            const businessPartnerIds = risks.map( risk => risk.bp_ID );
            const businessPartners = await tx.run(SELECT.from(srv.entities.BusinessPartners).where({ ID: businessPartnerIds }).columns([ "ID", "businessPartnerFullName", "businessPartnerIsBlocked" ]));
            // Convert in a map for easier lookup
            const businessPartnerMap = {};
            for (const businessPartner of businessPartners) {
            businessPartnerMap[businessPartner.ID] = businessPartner;
            }
            // Add Business Partner properties to risks result
            for (const risk of risks) {
            const businessPartner = businessPartnerMap[risk.bp_ID];
            if (businessPartner) risk.bp = businessPartner;
            }
            return risks;
            });
        const BupaService = await cds.connect.to('API_BUSINESS_PARTNER');
        srv.on('READ', srv.entities.BusinessPartners, async (req) => {
            // Workaround for CAP issue
            const mock = !cds.env.requires.API_BUSINESS_PARTNER.credentials;
            const tx = mock ? BupaService.tx(req) : BupaService;
            return await tx.run(req.query);
        });
}