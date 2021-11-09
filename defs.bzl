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
    return [TarLibrary(files = f),DefaultInfo(files = [t])]

tar = rule(
    implementation = _tar_library_impl,
    attrs = {
        "deps": attr.label_list(),
        "files": attr.label_keyed_string_dict(allow_files = True)
    }
)

M4Library = provider(attrs = {"srcs": "files to process"})
def _m4_impl(ctx):
    t = []
    for d in ctx.attr.deps:
        t += [d[M4Library].srcs]
    s = depset(ctx.attr.srcs,transitive = t)
    t = ctx.actions.declare_file("out")
    ctx.actions.run(nmemonic = "m4",executable = "/bin/m4",inputs = s,outputs = [t],arguments = ["-o",t] + ctx.attr.flags + s)
    return [M4Library(srcs = s),DefaultInfo(files = [t])]

m4 = rule(
    implementation = _m4_library_impl,
    attrs = {
        "deps": attr.label_list(),
        "srcs": attr.label_list(allow_files=True),
        "flags": attr.string_list()
    }
)

