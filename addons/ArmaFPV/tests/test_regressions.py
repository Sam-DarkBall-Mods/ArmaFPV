from pathlib import Path
import re
import unittest


ROOT = Path(__file__).resolve().parents[2]
ADDON = ROOT / "ArmaFPV"


def read(relative_path: str) -> str:
    return (ADDON / relative_path).read_text(encoding="utf-8")


class ArmaFpvRegressionTests(unittest.TestCase):
    def test_deployment_removes_one_item_without_rebuilding_cargo(self) -> None:
        source = read("functions/fn_fpv_createUavOnItemCheck.sqf")
        self.assertIn("_container addMagazineAmmoCargo [_item, -1", source)
        self.assertNotIn("clearMagazineCargo", source)
        self.assertNotIn("_newCargo", source)

    def test_global_settings_are_registered_on_every_machine(self) -> None:
        source = read("XEH_preInit.sqf")
        self.assertGreaterEqual(source.count("call CBA_fnc_addSetting"), 3)
        self.assertNotIn("serverCommandAvailable", source)
        self.assertNotIn("publicVariable", source)

    def test_drone_state_follows_locality(self) -> None:
        init_source = read("functions/fn_fpv_droneInit.sqf")
        config_source = read("includes/CfgVehicles.hpp")
        self.assertIn("if (!local _uav) exitWith", init_source)
        self.assertNotIn("if (!isServer) exitWith", init_source)
        self.assertIn("_uav setCaptive _isCaptive", init_source)
        self.assertRegex(config_source, r"\blocal\s*=")

    def test_jammer_elapsed_time_is_per_uav_and_frame_rate_independent(self) -> None:
        signal_source = read("functions/fn_fpv_getSignal.sqf")
        handler_source = read("functions/fn_fpv_handleSignal.sqf")
        self.assertNotIn("DB_timeInJammerZone", signal_source + handler_source)
        self.assertIn("DB_fpv_timeInJammerZone", signal_source)
        self.assertRegex(signal_source, r"_now\s*-\s*_lastSignalUpdate")

    def test_ppfx_oscillators_use_sqf_degrees(self) -> None:
        source = read("functions/fn_fpv_ppfx_update.sqf")
        self.assertNotIn("6.283", source)
        self.assertIn("_flickerHz * 360", source)
        self.assertIn("_microHz * 360", source)
        self.assertIn("sin (deg (", source)

    def test_unsupported_side_exits_before_creation(self) -> None:
        source = read("functions/fn_fpv_createUavOnItemCheck.sqf")
        guard = source.index('if (_sidePrefix isEqualTo "") exitWith {}')
        creation = source.index("createVehicle")
        self.assertLess(guard, creation)

    def test_crewed_uavs_are_cleaned_before_vehicle_deletion(self) -> None:
        for relative_path in (
            "functions/fn_fpv_addUavToInventory.sqf",
            "functions/fn_fpv_onDestroy.sqf",
        ):
            with self.subTest(relative_path=relative_path):
                source = read(relative_path)
                self.assertIn("deleteVehicleCrew _uav;", source)
                self.assertLess(source.index("deleteVehicleCrew"), source.index("deleteVehicle _uav"))

    def test_detonation_uses_uav_as_shot_parent_and_handles_killed(self) -> None:
        source = read("functions/fn_fpv_onDestroy.sqf")
        config_source = read("includes/CfgVehicles.hpp")
        self.assertIn("_shotParents = [_uav, _instigator]", source)
        self.assertLess(source.index("getShotParents"), source.index("deleteVehicle _uav"))
        self.assertRegex(config_source, r"\bkilled\s*=")

    def test_detonation_uses_multiplayer_uav_control_syntax(self) -> None:
        source = read("functions/fn_fpv_onDestroy.sqf")
        self.assertIn('UAVControl [_uav, "crew"]', source)
        self.assertIn('UAVControl [_uav, "allbutdead"]', source)
        self.assertNotIn("UAVControl _uav", source)

    def test_local_commands_are_routed_to_the_uav_owner(self) -> None:
        signal_lost = read("functions/fn_fpv_onSignalLost.sqf")
        disassembly = read("functions/fn_fpv_addUavToInventory.sqf")
        self.assertIn('remoteExecCall ["engineOn", _uav]', signal_lost)
        self.assertNotIn('remoteExec ["engineOn", 2]', signal_lost)
        self.assertIn("if (!local _uav) exitWith", disassembly)
        self.assertIn('remoteExecCall ["DB_fnc_fpv_addUavToInventory", _uav]', disassembly)
        self.assertNotIn("TakeBag", disassembly)

    def test_put_handler_follows_player_unit_changes(self) -> None:
        source = read("XEH_postInit.sqf")
        self.assertIn('["unit", {', source)
        self.assertNotIn('["loadout", {', source)
        self.assertIn("}, true] call CBA_fnc_addPlayerEventHandler", source)

    def test_current_namespace_and_array_syntax_is_used(self) -> None:
        sqf_source = "\n".join(path.read_text(encoding="utf-8") for path in ADDON.rglob("*.sqf"))
        self.assertNotIn('if (isNil "DB_', sqf_source)
        self.assertNotRegex(sqf_source, r"\bselect\s+\d+\b")
        self.assertIn('_uav isNil "DB_fpv_savedTime"', sqf_source)

    def test_addon_requires_arma_3_2_22(self) -> None:
        source = read("config.cpp")
        self.assertRegex(source, r"requiredVersion\s*=\s*2\.22\s*;")

    def test_default_text_is_sanitized_at_the_setting_boundary(self) -> None:
        preinit_source = read("XEH_preInit.sqf")
        settings_source = read("functions/fn_fpv_handleSettings.sqf")
        addon_sources = "\n".join(
            path.read_text(encoding="utf-8")
            for path in ADDON.rglob("*")
            if path.suffix.lower() in {".sqf", ".hpp", ".cpp"}
        )
        self.assertIn("_fnc_sanitizeText", preinit_source)
        self.assertIn("ArmaFPV_DefaultText", settings_source)
        self.assertNotIn("ArmaFPV_MainText", addon_sources)

    def test_function_registry_matches_function_files(self) -> None:
        config_source = read("includes/CfgFunctions.hpp")
        registered = set(re.findall(r"class\s+(fpv_[A-Za-z0-9_]+)\s*\{", config_source))
        files = {
            path.stem.removeprefix("fn_")
            for path in (ADDON / "functions").glob("fn_fpv_*.sqf")
        }
        self.assertEqual(files, registered)

    def test_forbidden_control_flow_is_absent(self) -> None:
        source = "\n".join(path.read_text(encoding="utf-8") for path in ADDON.rglob("*.sqf"))
        self.assertNotRegex(source, r"\bbreakOut\b")
        self.assertNotRegex(source, r"\bscopeName\b")


if __name__ == "__main__":
    unittest.main()
