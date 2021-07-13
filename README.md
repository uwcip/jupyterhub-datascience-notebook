## datascience notebook

This container builds a pretty heavyweight image for doing "data science" in
JupyterHub. You should use this container in a JupyterHub installation. It
inherits from the [base notebook](https://github.com/uwcip/jupyterhub-base-notebook)
and some changes should be made there instead of here.

If you do make changes to this container and want to deploy them you must also
update the version number in the [jupyterhub](https://github.com/uwcip/jupyterhub)
repository to reference the new container version number.

When you get ready to deploy a new version, check out the new version tag on
earth and run `make pull` to pull that version onto the host. If you do not do
that then users will not be able to use the container.
