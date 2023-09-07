import json
import subprocess
import sys
from typing import List, NamedTuple

"""
{
	'ActivityId': '91d407ec-6f0f-4084-9f19-d8dee022c6d8',
	'DataSourceAnalysis': [],
	'Details': 'TestSafeguardSessions.IntegrationTest',
	'EndTime': '2023-04-24T09:13:44.9565512+00:00',
	'Method': 'TestSafeguardSessions.IntegrationTest',
	'Name': 'TestAuthentication.query.pq',
	'StartTime': '2023-04-24T09:13:44.0146567+00:00',
	'Output': [
		{
			'Result': 'Success',
			'Notes': 'All 14 Passed !!! ?',
			'Details': '100% success rate'
		}
	],
	'RowCount': 1,
	'Status': 'Passed',
	'Type': 'PQTest.RunTest'
}
"""


class TestCase(NamedTuple):
    Result: str
    Notes: str
    Details: str


class TestSuite(NamedTuple):
    ActivityId: str
    DataSourceAnalysis: list
    Details: str
    EndTime: str
    Method: str
    Name: str
    StartTime: str
    Output: List[TestCase]
    RowCount: int
    Status: str
    Type: str


pqtest_output = subprocess.run(["make", "-s", "unit-tests"], shell=True, capture_output=True)

# results = "\n".join(pqtest_output.stdout.decode("ISO-8859-2").splitlines()[6:])

as_json = json.loads(pqtest_output.stdout.decode("ISO-8859-2"))

tests = [
    TestSuite(
        **(
            dict(
                result,
                **{"Output": [TestCase(**testcase) for testcase in result["Output"]]}
            )
        )
    )
    for result in as_json
]

if any(len(test.Output) > 1 for test in tests):
    sys.exit(1)

sys.exit(0)
