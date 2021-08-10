FROM ghcr.io/uwcip/jupyterhub-base-notebook:v1.2.1

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
RUN conda install --quiet --yes \
    "r-base"  \
    "r-caret" \
    "r-crayon" \
    "r-devtools" \
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
    && conda clean --all -f -y \
    && fix-permissions "${CONDA_DIR}" \
    && fix-permissions "/home/${NB_USER}" \
    && true

# install Python3 packages
RUN conda install --quiet --yes \
    "altair" \
    "beautifulsoup4" \
    "bokeh" \
    "bottleneck" \
    "cloudpickle" \
    "conda-forge::blas=*=openblas" \
    "cython" \
    "dask" \
    "dill" \
    "h5py" \
    "ipympl"\
    "ipywidgets" \
    "matplotlib-base" \
    "numba" \
    "numexpr" \
    "pandas" \
    "patsy" \
    "protobuf" \
    "pytables" \
    "scikit-image" \
    "scikit-learn" \
    "scipy" \
    "seaborn" \
    "sqlalchemy" \
    "statsmodels" \
    "sympy" \
    "widgetsnbextension" \
    "xlrd" \
    "psycopg2" \
    && conda clean --all -f -y \
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

# install additional pip packages. be careful adding things here that might
# disrupt other versions. (for example, adding tensorflow currently downgrades
# numpy so avoid adding tensorflow for now.)
RUN pip install --no-cache-dir \
    "nltk" \
    "vaderSentiment" \
    "line-profiler" \
    "pystan<3" \
    "pymc3" \
    "arviz" \
    "wordcloud" \
    "textblob" \
    "tabulate" \
    "dateparser" \
    "gensim" \
    "nx_altair" \
    "plotly" \
    "cufflinks" \
    "transformers[torch]" \
    && fix-permissions "${CONDA_DIR}" \
    && fix-permissions "/home/${NB_USER}" \
    && true

# ensure that we run the container as the notebook user
USER ${NB_UID}
WORKDIR ${HOME}
