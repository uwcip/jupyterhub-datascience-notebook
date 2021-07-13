FROM ghcr.io/uwcip/jupyterhub-base-notebook:v1.0.0

# github metadata
LABEL org.opencontainers.image.source=https://github.com/uwcip/jupyterhub-datascience-notebook

USER root

# ffmpeg for matplotlib anim & dvipng+cm-super for latex labels
RUN apt-get -q update && \
    apt-get install -y --no-install-recommends ffmpeg dvipng cm-super && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# tesseract for OCR work
RUN apt-get -q update && \
    apt-get install -y --no-install-recommends tesseract-ocr-all && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

USER ${NB_UID}

# install R and some libraries
RUN conda install --quiet --yes \
    "r-base=4.1.0"  \
    "r-caret=6.*" \
    "r-crayon=1.4*" \
    "r-devtools=2.4*" \
    "r-forecast=8.15*" \
    "r-hexbin=1.28*" \
    "r-htmltools=0.5*" \
    "r-htmlwidgets=1.5*" \
    "r-irkernel=1.2*" \
    "r-randomforest=4.6*" \
    "r-rcurl=1.98*" \
    "r-rmarkdown=2.9*" \
    "r-rodbc=1.3*" \
    "r-rsqlite=2.2*" \
    "r-shiny=1.6*" \
    "r-tidymodels=0.1*" \
    "r-tidyverse=1.3*" \
    "r-statnet=2019.*" \
    "rpy2=3.4*" \
    "unixodbc=2.3.*" \
    "r-stm=1.3*" \
    "r-rpostgres=1.3.*" \
    && conda clean --all -f -y \
    && fix-permissions "${CONDA_DIR}" \
    && fix-permissions "/home/${NB_USER}" \
    && true

# install Python3 packages
RUN conda install --quiet --yes \
    "altair=4.1.*" \
    "beautifulsoup4=4.9.*" \
    "bokeh=2.3.*" \
    "bottleneck=1.3.*" \
    "cloudpickle=1.6.*" \
    "conda-forge::blas=*=openblas" \
    "cython=0.29.*" \
    "dask=2021.6.*" \
    "dill=0.3.*" \
    "h5py=3.3.*" \
    "ipympl=0.7.*"\
    "ipywidgets=7.6.*" \
    "matplotlib-base=3.4.*" \
    "numba=0.53.*" \
    "numexpr=2.7.*" \
    "pandas=1.3.*" \
    "patsy=0.5.*" \
    "protobuf=3.17.*" \
    "pytables=3.6.*" \
    "scikit-image=0.18.*" \
    "scikit-learn=0.24.*" \
    "scipy=1.7.*" \
    "seaborn=0.11.*" \
    "sqlalchemy=1.4.*" \
    "statsmodels=0.12.*" \
    "sympy=1.8.*" \
    "widgetsnbextension=3.5.*" \
    "xlrd=2.0.*" \
    "psycopg2=2.8.*" \
    && conda clean --all -f -y \
    && fix-permissions "${CONDA_DIR}" \
    && fix-permissions "/home/${NB_USER}" \
    && true

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
    "nltk==3.6.*" \
    "vaderSentiment==3.3.*" \
    "line-profiler==3.3.*" \
    "pystan==2.19.1.1" \
    "pymc3==3.11.*" \
    "arviz==0.11.*" \
    "wordcloud==1.8.*" \
    "textblob==0.15.*" \
    "tabulate==0.8.*" \
    "dateparser==1.0.*" \
    "gensim==4.0.*" \
    "nx_altair==0.1.*" \
    "plotly==4.14.*" \
    "cufflinks==0.17.*" \
    && fix-permissions "${CONDA_DIR}" \
    && fix-permissions "/home/${NB_USER}" \
    && true

# ensure that we run the container as the notebook user
USER ${NB_UID}
WORKDIR ${HOME}
