"""Implementation of the `default_input_file_attributes_aspect` aspect."""

load("@build_bazel_rules_apple//apple:providers.bzl", "AppleBundleInfo")
load(":providers.bzl", "InputFileAttributesInfo")

# Utility

def _is_test_target(target):
    """Returns whether the given target is for test purposes or not."""
    if AppleBundleInfo not in target:
        return False
    return target[AppleBundleInfo].product_type in (
        "com.apple.product-type.bundle.ui-testing",
        "com.apple.product-type.bundle.unit-test",
    )

# Aspects

def _default_input_file_attributes_aspect_impl(target, ctx):
    if InputFileAttributesInfo in target:
        return []

    if CcInfo in target:
        srcs = ("srcs")
    else:
        srcs = ()

    non_arc_srcs = ()
    hdrs = ()
    if ctx.rule.kind == "cc_library":
        excluded = ("deps", "interface_deps", "win_def_file")
        hdrs = ("hdrs", "textual_hdrs")
    elif ctx.rule.kind == "objc_library":
        excluded = ("deps", "runtime_deps")
        non_arc_srcs = ("non_arc_srcs")
        hdrs = ("hdrs", "textual_hdrs")
    elif ctx.rule.kind == "swift_library":
        excluded = ("deps", "private_deps")
    elif AppleBundleInfo in target:
        excluded = ["deps"]
        if _is_test_target(target):
            excluded.append("test_host")
    else:
        excluded = ("deps")

    return [
        InputFileAttributesInfo(
            excluded = excluded,
            non_arc_srcs = non_arc_srcs,
            srcs = srcs,
            hdrs = hdrs,
        ),
    ]

default_input_file_attributes_aspect = aspect(
    implementation = _default_input_file_attributes_aspect_impl,
    attr_aspects = ["*"],
)