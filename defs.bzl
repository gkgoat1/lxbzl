TarLibrary = provider(attrs = {"files": "files to tar"})
def _tar_impl(ctx):
    f = {}
    for d in ctx.attr.deps:
        for k,v in enumerate(d[TarLibrary].files):
            f[k] = v
    for v,k in ctx.attr.files:
        f[k] = ctx.actions.declare_file(k)
        ctx.actions.run(mnemonic = "cp",executable = "/bin/cp",arguments = [v,f[k]],outputs = [f[k]], inputs = [v])
    t = ctx.actions.declare_file("__target.tar")
    ctx.actions.run(nmemonic = "tar",executable = "/bin/tar",arguments = ["-cvf",t], outputs = [t], inputs = values(f))
    return [TarLibrary(files = f),DefaultInfo]

tar = rule(
    implementation = _tar_library_impl,
    attrs = {
        "deps": attr.label_list(),
        "files": attr.label_keyed_string_dict(allow_files = True)
    }
)

