#!/usr/bin/env nu

const METADATA_FILE = "packaging-metadata.yaml"
const VERSION_RESOLVER = "utils/resolve-next-version.nu"

def main [
    app_name: string
    output_dir: string
] {
    print $"[INFO] Starting Debian packaging for ($app_name)"

    if not ($METADATA_FILE | path exists) {
        error make { msg: $"Metadata file not found: ($METADATA_FILE)" }
    }

    let metadata = open $METADATA_FILE
    let app = ($metadata.applications | where name == $app_name | first)

    if ($app | is-empty) {
        error make { msg: $"App '($app_name)' not found in metadata" }
    }

    let app_folder = ($app.folder | path expand)
    let pubspec_path = ($app_folder | path join "pubspec.yaml")

    if not ($pubspec_path | path exists) {
        error make { msg: $"pubspec.yaml not found at ($pubspec_path)" }
    }

    let pubspec = open $pubspec_path
    let app_version = $pubspec.version
    let app_description = ($pubspec.description? | default "Mechanix application")
    let pkg_arch = (^dpkg --print-architecture | str trim)
    let pkg_name = $"mechanix-($app_name)"
    let dependencies = (($app.dependencies? | default []) | str join ", ")
    let resolver_path = ($VERSION_RESOLVER | path expand)

    let version_data = if ($resolver_path | path exists) {
        try {
            (^nu $resolver_path
                --format "deb"
                --name $pkg_name
                --upstream $app_version
                | from json)
        } catch {
            print "[WARN] Version resolver failed, defaulting to revision 1"
            {
                full_version: $"($app_version)-1"
                next_revision: 1
                upstream_version: $app_version
            }
        }
    } else {
        print $"[WARN] Version resolver not found at: ($resolver_path)"
        {
            full_version: $"($app_version)-1"
            next_revision: 1
            upstream_version: $app_version
        }
    }

    let pkg_version = $version_data.full_version
    let build_dir = ($app_folder | path join "build" "elinux" "arm64" "release" "bundle")
    let alt_build_dir = ($app_folder | path join "build" "elinux" "aarch64" "release" "bundle")
    let bundle_dir = if ($build_dir | path exists) {
        $build_dir
    } else if ($alt_build_dir | path exists) {
        $alt_build_dir
    } else {
        error make {
            msg: $"Build directory not found. Tried: ($build_dir), ($alt_build_dir)"
        }
    }

    let pkg_dir = "package"
    rm -rf $pkg_dir
    mkdir $pkg_dir
    mkdir $"($pkg_dir)/DEBIAN"
    mkdir $"($pkg_dir)/usr/bin"
    mkdir $"($pkg_dir)/usr/share/mechanix/($pkg_name)"

    let control_content = $"Package: ($pkg_name)
Version: ($pkg_version)
Section: utils
Priority: optional
Architecture: ($pkg_arch)
Maintainer: ($app.maintainer)
Depends: ($dependencies)
Description: ($app_description)
"
    $control_content | save -f $"($pkg_dir)/DEBIAN/control"

    let binary_src = ($bundle_dir | path join $app.binary)
    let binary_dest = $"($pkg_dir)/usr/bin/($app.binary)"
    if not ($binary_src | path exists) {
        error make { msg: $"Binary not found at ($binary_src)" }
    }

    cp $binary_src $binary_dest
    chmod 755 $binary_dest

    let data_src = ($bundle_dir | path join "data")
    if ($data_src | path exists) {
        cp -r $data_src $"($pkg_dir)/usr/share/mechanix/($pkg_name)/"
    }

    let lib_src = ($bundle_dir | path join "lib")
    if ($lib_src | path exists) {
        cp -r $lib_src $"($pkg_dir)/usr/share/mechanix/($pkg_name)/"
    }

    let output_path = ($output_dir | path expand)
    if not ($output_path | path exists) {
        mkdir $output_path
    }

    let deb_filename = $"($pkg_name)_($pkg_version)_($pkg_arch).deb"
    let deb_path = ($output_path | path join $deb_filename)
    ^dpkg-deb --build $pkg_dir $deb_path

    rm -rf $pkg_dir

    print $"[SUCCESS] Package created: ($deb_path)"
    print $deb_path
}
