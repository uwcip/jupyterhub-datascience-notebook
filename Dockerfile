FROM ghcr.io/uwcip/jupyterhub-base-notebook:v1.6.3

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
    apt-get clean && rm -rf /var/lib/apt/lists/*

USER ${NB_UID}

# install R and some libraries
RUN mamba install --quiet --yes \
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
    && mamba clean --all -f -y \
    && fix-permissions "${CONDA_DIR}" \
    && fix-permissions "/home/${NB_USER}" \
    && true

# install Python3 packages
RUN mamba install --quiet --yes \
    "altair" \
    "arviz" \
    "beautifulsoup4" \
    "bokeh" \
    "bottleneck" \
    "cloudpickle" \
    "openblas" \
    "cython" \
    "dask" \
    "dateparser" \
    "dill" \
    "gensim" \
    "h5py" \
    "ipympl"\
    "ipywidgets" \
    "matplotlib-base" \
    "nltk" \
    "numba" \
    "numexpr" \
    "pandas" \
    "patsy" \
    "plotly" \
    "protobuf" \
    "psycopg2" \
    "pymc3" \
    "pystan<3" \
    "pytables" \
    "python-cufflinks" \
    "pytorch" \
    "scikit-image" \
    "scikit-learn" \
    "scipy" \
    "seaborn" \
    "sqlalchemy" \
    "statsmodels" \
    "sympy" \
    "tabulate" \
    "tensorflow" \
    "textblob" \
    "transformers" \
    "vadersentiment" \
    "widgetsnbextension" \
    "wordcloud" \
    "xlrd" \
    && mamba clean --all -f -y \
    && fix-permissions "${CONDA_DIR}" \
    && fix-permissions "/home/${NB_USER}" \
    && true

# install signnet which does not have a conda package at the moment.
WORKDIR /tmp
RUN wget --quiet "https://cran.r-project.org/src/contrib/signnet_0.7.1.tar.gz" && \
    R CMD INSTALL signnet_0.7.1.tar.gz && \
    rm -rf signnet_0.7.1.tar.gz && \
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

# import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME="/home/${NB_USER}/.cache/"
RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" && \
    fix-permissions "/home/${NB_USER}"

# ensure that we run the container as the notebook user
USER ${NB_UID}
WORKDIR ${HOME}
