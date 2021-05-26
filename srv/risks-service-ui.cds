using RiskService from './risk-service';

annotate RiskService.Risks with {
    title  @title : 'Title';
    prio   @title : 'Priority';
    descr  @title : 'Description';
    miti   @title : 'Mitigation';
    bp     @title : 'Business Partner';
    impact @title : 'Impact';
}

annotate RiskService.Mitigations with {
    ID          @(
        UI.Hidden,
        Common : {Text : description}
    );
    description @title : 'Description';
    owner       @title : 'Owner';
    timeline    @title : 'Timeline';
    risks       @title : 'Risks';
}

annotate RiskService.Risks with @(UI : {
    HeaderInfo       : {
        TypeName       : 'Risk',
        TypeNamePlural : 'Risks'
    },
    SelectionFields  : [prio],
    LineItem         : [
        {Value : title},
        {Value : miti_ID},
        {Value : bp_ID},
        {
            Value       : prio,
            Criticality : criticality
        },
        {
            Value       : impact,
            Criticality : criticality
        }
    ],
    Facets           : [{
        $Type  : 'UI.ReferenceFacet',
        Label  : 'Main',
        Target : '@UI.FieldGroup#Main'
    }],
    FieldGroup #Main : {Data : [
        {Value : title},
        {Value : miti_ID},
        {Value : descr},
        {
            Value       : prio,
            Criticality : criticality
        },
        {Value : bp_ID},
        {Value : bp.businessPartnerIsBlocked},
        {
            Value       : impact,
            Criticality : criticality
        }
    ]}
}, ) {

};

annotate RiskService.Risks with {
    miti @(Common : {
        //show text, not id for mitigation in the context of risks
        Text            : miti.description,
        TextArrangement : #TextOnly,
        ValueList       : {
            Label          : 'Mitigations',
            CollectionPath : 'Mitigations',
            Parameters     : [
                {
                    $Type             : 'Common.ValueListParameterInOut',
                    LocalDataProperty : miti_ID,
                    ValueListProperty : 'ID'
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'description'
                }
            ]
        }
    });
    bp   @(Common : {
        Text            : bp.businessPartnerFullName,
        TextArrangement : #TextOnly,
        ValueList       : {
            Label          : 'Business Partners',
            CollectionPath : 'BusinessPartners',
            Parameters     : [
                {
                    $Type             : 'Common.ValueListParameterInOut',
                    LocalDataProperty : bp_ID,
                    ValueListProperty : 'ID'
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'businessPartnerFullName'
                }
            ]
        }
    })
}

annotate RiskService.BusinessPartners with {
    ID                       @(
        UI.Hidden,
        Common : {Text : businessPartnerFullName}
    );
    businessPartnerFullName  @title : 'Business Partner Name';
    businessPartnerIsBlocked @title : 'Business Partner Blocked';
}
