section TestReportUtilities;

ReportUtilities = SafeguardPasswords.ImportModule("ReportUtilities.pqm");
ReportUtilities.GetAssetAccountOwnershipDataTable = ReportUtilities[GetAssetAccountOwnershipDataTable];

TestAssetAccountReportGeneration = () =>
    let
        fakeData = [
            Accounts = #table({"Id","Name","Asset"},{{1,"test1",[Id=1,AssetPartitionId=-1]},{2,"test2",[Id=2,AssetPartitionId=-1]}}),
            Owners = [
                AccountOwners = #table({"Name","EmailAddress","PrincipalKind","IdentityProviderName","Direct","ViaTags"},
                    {{"test","test@test.com","prin","idp",true,[]}}),
                AssetOwners = #table({"Name","EmailAddress","PrincipalKind","IdentityProviderName","Direct","ViaTags"},
                    {{"test1","test@test.com","prin","idp",true,[]}}),
                PartitionOwners = #table({"Name","EmailAddress","PrincipalKind","IdentityProviderName"},
                    {{"test2","test@test.com","prin","idp"}})
            ]
        ],
        
        expectedReport = #table({"Id","Name","Asset.Id","AssetPartitionId","Owners.Name","Owners.EmailAddress","Owners.PrincipalKind","Owners.IdentityProviderName","Owners.Direct"},
            {
                {1,"test1",1,-1,"test","test@test.com","prin","idp",true},
                {1,"test1",1,-1,"test1","test@test.com","prin","idp",true},
                {1,"test1",1,-1,"test2","test@test.com","prin","idp",null},
                {2,"test2",2,-1,"test","test@test.com","prin","idp",true},
                {2,"test2",2,-1,"test1","test@test.com","prin","idp",true},
                {2,"test2",2,-1,"test2","test@test.com","prin","idp",null}
            }),

        report = ReportUtilities.GetAssetAccountOwnershipDataTable("fakeurl",[Response=fakeData]),

        facts = {
            Fact("AssetAccountReport is correct", expectedReport, report)
        }

    in
        facts;

shared TestRequest.UnitTest = [
    facts = {
        TestAssetAccountReportGeneration()
    },
    report = Summarize(facts)
][report];