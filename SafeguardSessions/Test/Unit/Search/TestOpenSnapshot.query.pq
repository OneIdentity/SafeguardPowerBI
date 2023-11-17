section TestOpenSnapshot;

OpenSnapshot = Extension.ImportModule("OpenSnapshot.pqm")[OpenSnapshot];

TestOpenSnapshotIsSuccessful = () =>
    let
        fakeSnapshotResponse = FakeRawResponse([
            body = [snapshot = "dummy_snapshot_id"]
        ]),
        snapshot = OpenSnapshot(
            "dummy_url", "dummy_session_id", [
                OpenSnapshotResponse = fakeSnapshotResponse
            ]
        )
    in
        Fact("Snapshot is returned correctly", "dummy_snapshot_id", snapshot);

TestOpenSnapshotRaisesError = () =>
    let
        AssertOpenSnapshotFailure = (
            fakeSnapshotResponse as binary, expectedReason as text, expectedMessage as text, expectedDetail as record
        ) =>
            let
                requestUrl = "http://dummy_url/api/audit/sessions/_snapshot"
            in
                AssertError(
                    "An error is raised if fields are missing in the response received",
                    OpenSnapshot,
                    {requestUrl, "dummy_session_id", [
                        OpenSnapshotResponse = fakeSnapshotResponse
                    ]},
                    [
                        Reason = expectedReason,
                        Message = expectedMessage,
                        Detail = expectedDetail & [RequestUrl = requestUrl]
                    ]
                ),
        cases = {
            {
                FakeRawResponse([invalid = "response"]),
                "Not Parsable Response",
                "Error 10002: The source IP returned a response with missing fields.",
                [
                    Cause = [invalid = "response"],
                    MissingField = "body.snapshot",
                    ManuallyHandled = true,
                    ErrorCode = 10002
                ]
            },
            {
                FakeRawResponse([#"error" = "reason"], [
                    Response.Status = 429
                ]),
                "Snapshot Quota Error",
                "Error 4290: Snapshot quota exceeded.",
                [
                    Cause = [#"error" = "reason"],
                    ManuallyHandled = true,
                    ErrorCode = 4290
                ]
            }
        },
        facts = ProvideDataForTest(cases, AssertOpenSnapshotFailure)
    in
        facts;

shared TestOpenSnapshot.UnitTest = [
    facts = {TestOpenSnapshotIsSuccessful(), TestOpenSnapshotRaisesError()},
    report = Summarize(facts)
][report];
