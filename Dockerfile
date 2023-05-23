FROM ghcr.io/uwcip/jupyterhub-base-notebook:v1.8.5

# github metadata
LABEL org.opencontainers.image.source=https://github.com/uwcip/jupyterhub-datascience-notebook

USER root

# install updates and dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -q update && apt-get -y upgrade && \
    # ffmpeg for matplotlib anim & dvipng+cm-super for latex labels
    apt-get install -y --no-install-recommends ffmpeg dvipng cm-super && \
    # tesseract for OCR work
    apt-get install -y --no-install-recommends tesseract-ocr-all && \
    # Java for Spark
    apt-get install -y --no-install-recommends default-jdk && \
    # NLopt (non-linear optmization) package
    apt-get install -y --no-install-recommends libnlopt-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

USER ${NB_UID}

# install R and some libraries
RUN conda install --quiet --yes \
    "r-base"  \
    "r-caret" \
    "r-crayon" \
    "r-devtools" \
    "r-e1071" \
    "r-forecast" \
    "r-hexbin" \
    "r-htmltools" \
    "r-htmlwidgets" \
    "r-irkernel" \
    "r-randomforest" \
    "r-rcurl" \
    "r-rmarkdown" \
    "r-rodbc" \
    "r-rsqlite" \
    "r-shiny" \
    "r-tidymodels" \
    "r-tidyverse" \
    "unixodbc" \
    "r-statnet" \
    "rpy2" \
    "r-stm" \
    "r-rpostgres" \
    "r-igraph" \
    "r-rgexf" \
    "r-cowplot" \
    "r-webshot" \
    "r-arrow" \
    && conda clean --all -f -y \
    && fix-permissions "${CONDA_DIR}" \
    && fix-permissions "/home/${NB_USER}" \
    && true

# install Python3 packages
RUN conda install --quiet --yes \
#     "altair" \
    "arviz" \
#     "beautifulsoup4" \
    "bokeh" \
#     "bottleneck" \
#     "cloudpickle" \
#     "openblas" \
#     "cython" \
#     "dask" \
    "dateparser" \
#     "dill" \
#     "gensim" \
#     "h5py" \
#     "ipympl"\
#     "ipywidgets" \
    "matplotlib-base" \
    "networkx" \
    "nlopt" \
    "nltk" \
    "numba" \
    "numexpr" \
    "pandas" \
#     "patsy" \
    "plotly" \
    "protobuf" \
    "psycopg2" \
    "pyarrow" \
    "pymc3" \
    "pyspark" \
#     "pystan<3" \
#     "pytables" \
#     "python-cufflinks" \
#     "pytorch" \
#     "scikit-image" \
    "scikit-learn" \
    "scipy" \
    "seaborn" \
    "sqlalchemy" \
    "statsmodels" \
#     "sympy" \
#     "tabulate" \
#     "tensorflow" \
#     "textblob" \
    "transformers" \
    "umap-learn" \
    "vadersentiment" \
#     "widgetsnbextension" \
#     "wordcloud" \
    "xlrd" \
    && conda clean --all -f -y \
    && fix-permissions "${CONDA_DIR}" \
    && fix-permissions "/home/${NB_USER}" \
    && true

# install signnet which does not have a conda package at the moment.
WORKDIR /tmp
RUN wget --quiet "https://cran.r-project.org/src/contrib/signnet_1.0.0.tar.gz" && \
    R CMD INSTALL signnet_1.0.0.tar.gz && \
    rm -rf signnet_1.0.0.tar.gz && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# install facets which does not have a pip or conda package at the moment.
# according to the docs this does NOT require a call to "enable" the extension.
WORKDIR /tmp
RUN git clone https://github.com/PAIR-code/facets.git && \
    jupyter nbextension install facets/facets-dist/ --sys-prefix && \
    rm -rf /tmp/facets && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# install datapy to access databricks
RUN --mount=type=secret,id=PYPI_PASSWORD \
pip install --extra-index-url=https://$(cat /run/secrets/PYPI_PASSWORD)@pkgs.dev.azure.com/uwcip/uwcip/_packaging/uwcip-pypi-dev/pypi/simple datapy

# import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME="/home/${NB_USER}/.cache/"
RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" && \
    fix-permissions "/home/${NB_USER}"

# ensure that we run the container as the notebook user
USER ${NB_UID}
WORKDIR ${HOME}
