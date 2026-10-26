import json
import unittest
from pathlib import Path
from xml.etree import ElementTree

ROOT = Path(__file__).parents[1]
EXAMPLES = ROOT / "examples"


class FixtureContractTests(unittest.TestCase):
    def test_xml_fixtures_are_well_formed(self):
        fixtures = sorted(EXAMPLES.rglob("*.xml"))
        self.assertGreaterEqual(len(fixtures), 2)
        for fixture in fixtures:
            with self.subTest(fixture=fixture.relative_to(ROOT)):
                ElementTree.parse(fixture)

    def test_harvester_json_is_valid_and_clearly_marks_placeholder(self):
        config = json.loads((EXAMPLES / "02-harvest" / "harvester.json").read_text(encoding="utf-8"))
        self.assertEqual(config["type"], "csw")
        self.assertIn("example.org", config["config"]["capabilitiesUrl"])
        self.assertTrue(any("placeholder" in note.lower() for note in config["notes"]))

    def test_record_fixture_uses_reserved_synthetic_uuid_and_title(self):
        record = ElementTree.parse(EXAMPLES / "01-record-create" / "record.xml").getroot()
        strings = [node.text or "" for node in record.iter() if node.tag.rsplit("}", 1)[-1] == "CharacterString"]
        self.assertIn("00000000-0000-4000-8000-000000000001", strings)
        self.assertIn("Synthetic Test Dataset — DO NOT PUBLISH", strings)


class ShellSafetyContracts(unittest.TestCase):
    def test_all_shell_examples_use_fail_fast_mode(self):
        scripts = sorted(EXAMPLES.rglob("*.sh"))
        self.assertGreaterEqual(len(scripts), 4)
        for script in scripts:
            with self.subTest(script=script.relative_to(ROOT)):
                text = script.read_text(encoding="utf-8")
                self.assertIn("set -euo pipefail", text)

    def test_http_scripts_fail_on_http_errors(self):
        for relative in (
            "examples/02-harvest/create.sh",
            "examples/03-csw-search/search.sh",
            "examples/04-es-index/check.sh",
        ):
            with self.subTest(script=relative):
                text = (ROOT / relative).read_text(encoding="utf-8")
                self.assertIn("--fail-with-body", text)

    def test_csw_search_uses_script_relative_fixture_and_checks_counts(self):
        script = (EXAMPLES / "03-csw-search" / "search.sh").read_text(encoding="utf-8")
        self.assertIn('"$DIR/getrecords.xml"', script)
        self.assertIn('numberOfRecordsMatched', script)
        self.assertIn('[[ "$empty_count" == "0" ]]', script)
        self.assertNotIn("curl -sS", script)

    def test_harvester_script_does_not_claim_to_trigger_a_run(self):
        script = (EXAMPLES / "02-harvest" / "create.sh").read_text(encoding="utf-8")
        self.assertIn("does not trigger a harvest run", script)
        self.assertNotIn("run once + status", script)


if __name__ == "__main__":
    unittest.main()
