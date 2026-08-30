let version = HEMTT.project().version().to_string();
let main_authority = "db_armafpv_" + version;

fn rename_signed_pbo(folder, old_name, new_name, authority) {
    let old_pbo = folder.join(old_name + ".pbo");
    let new_pbo = folder.join(new_name + ".pbo");
    if !old_pbo.move(new_pbo) {
        fatal("Failed to rename " + old_name + ".pbo");
    }

    let old_signature = folder.join(old_name + ".pbo." + authority + ".bisign");
    let new_signature = folder.join(new_name + ".pbo." + authority + ".bisign");
    if old_signature.exists() && !old_signature.move(new_signature) {
        fatal("Failed to rename signature for " + old_name + ".pbo");
    }
}

rename_signed_pbo(
    HEMTT_OUT.join("addons"),
    "ArmaFPV_ArmaFPV",
    "ArmaFPV",
    main_authority
);

let compat_authority = main_authority + "_ArmaFPV_ArmaFPV_Compat";
let compat_root = HEMTT_OUT
    .join("optionals")
    .join("@ArmaFPV_ArmaFPV_Compat");
rename_signed_pbo(
    compat_root.join("addons"),
    "ArmaFPV_ArmaFPV_Compat",
    "ArmaFPV_Compat",
    compat_authority
);
if !compat_root.move(HEMTT_OUT.join("optionals").join("@ArmaFPV_Compat")) {
    fatal("Failed to rename ArmaFPV compatibility mod folder");
}

let interop_authority = main_authority + "_ArmaFPV_SDB_InteropTweaks";
let interop_root = HEMTT_OUT
    .join("optionals")
    .join("@ArmaFPV_SDB_InteropTweaks");
rename_signed_pbo(
    interop_root.join("addons"),
    "ArmaFPV_SDB_InteropTweaks",
    "SDB_InteropTweaks",
    interop_authority
);
if !interop_root.move(HEMTT_OUT.join("optionals").join("@SDB_InteropTweaks")) {
    fatal("Failed to rename SDB interoperability mod folder");
}
