# Generated by Neurodocker version 0.4.0
# Timestamp: 2018-07-08 20:06:19 UTC
# 
# Thank you for using Neurodocker. If you discover any issues
# or ways to improve this software, please submit an issue or
# pull request on our GitHub repository:
# 
#     https://github.com/kaczmarj/neurodocker

FROM neurodebian:stretch-non-free

ARG DEBIAN_FRONTEND="noninteractive"

ENV LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    ND_ENTRYPOINT="/neurodocker/startup.sh"
RUN export ND_ENTRYPOINT="/neurodocker/startup.sh" \
    && apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           apt-utils \
           bzip2 \
           ca-certificates \
           curl \
           locales \
           unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG="en_US.UTF-8" \
    && chmod 777 /opt && chmod a+s /opt \
    && mkdir -p /neurodocker \
    && if [ ! -f "$ND_ENTRYPOINT" ]; then \
         echo '#!/usr/bin/env bash' >> "$ND_ENTRYPOINT" \
    &&   echo 'set -e' >> "$ND_ENTRYPOINT" \
    &&   echo 'if [ -n "$1" ]; then "$@"; else /usr/bin/env bash; fi' >> "$ND_ENTRYPOINT"; \
    fi \
    && chmod -R 777 /neurodocker && chmod a+s /neurodocker

ENTRYPOINT ["/neurodocker/startup.sh"]

RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           fsl \
           gcc \
           g++ \
           graphviz \
           tree \
           less \
           ncdu \
           tig \
           swig \
           wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN sed -i '$isource /etc/fsl/fsl.sh' $ND_ENTRYPOINT

RUN useradd --no-user-group --create-home --shell /bin/bash neuro
USER neuro

ENV CONDA_DIR="/opt/miniconda-latest" \
    PATH="/opt/miniconda-latest/bin:$PATH"
RUN export PATH="/opt/miniconda-latest/bin:$PATH" \
    && echo "Downloading Miniconda installer ..." \
    && conda_installer="/tmp/miniconda.sh" \
    && curl -fsSL --retry 5 -o "$conda_installer" https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && bash "$conda_installer" -b -p /opt/miniconda-latest \
    && rm -f "$conda_installer" \
    && conda update -yq -nbase conda \
    && conda config --system --prepend channels conda-forge \
    && conda config --system --set auto_update_conda false \
    && conda config --system --set show_channel_urls true \
    && sync && conda clean -tipsy && sync \
    && conda create -y -q --name neuro \
    && conda install -y -q --name neuro \
           python=3.6 \
           pytest \
           jupyter \
           jupyterlab \
           jupyter_contrib_nbextensions \
           traits \
           pandas \
           matplotlib \
           scikit-learn \
           scikit-image \
           seaborn \
           nbformat \
           nb_conda \
    && sync && conda clean -tipsy && sync \
    && bash -c "source activate neuro \
    &&   pip install  --no-cache-dir \
             https://github.com/nipy/nipype/tarball/master \
             https://github.com/INCF/pybids/tarball/master \
             nilearn \
             nibabel \
             nipy \
             duecredit \
             nbval \
             pymvpa2 \
             keras \
             tensorflow \
             pybids" \
    && rm -rf ~/.cache/pip/* \
    && sync \
    && sed -i '$isource activate neuro' $ND_ENTRYPOINT

RUN bash -c 'source activate neuro && jupyter nbextension enable exercise2/main && jupyter nbextension enable spellchecker/main'

USER root

RUN mkdir /data && chmod 777 /data && chmod a+s /data

RUN mkdir /output && chmod 777 /output && chmod a+s /output

RUN mkdir /templates && chmod 777 /templates && chmod a+s /templates

RUN rm -rf /opt/conda/pkgs/*

USER neuro

RUN curl -L -o /data/dataset.zip https://www.dropbox.com/s/4k4npu7wsz1rtwk/dataset.zip?dl=1 && unzip /data/dataset.zip -d /data/ && rm /data/dataset.zip

RUN curl -L -o /output/datasink.zip https://www.dropbox.com/s/torun2z8vchyhsd/datasink.zip?dl=1 && unzip /output/datasink.zip -d /output/ && rm /output/datasink.zip

COPY ["templates", "/templates"]

COPY ["notebooks", "/home/neuro/notebooks"]

COPY ["slides", "/home/neuro/slides"]

COPY ["program.ipynb", "/home/neuro/program.ipynb"]

COPY ["test_notebooks.py", "/home/neuro/test_notebooks.py"]

RUN mkdir -p ~/.jupyter && echo c.NotebookApp.ip = \"0.0.0.0\" > ~/.jupyter/jupyter_notebook_config.py

WORKDIR /home/neuro

USER root

RUN chown -R neuro /home/neuro

USER neuro

CMD ["jupyter-notebook"]

RUN echo '{ \
    \n  "pkg_manager": "apt", \
    \n  "instructions": [ \
    \n    [ \
    \n      "base", \
    \n      "neurodebian:stretch-non-free" \
    \n    ], \
    \n    [ \
    \n      "install", \
    \n      [ \
    \n        "fsl", \
    \n        "gcc", \
    \n        "g++", \
    \n        "graphviz", \
    \n        "tree", \
    \n        "less", \
    \n        "ncdu", \
    \n        "tig", \
    \n        "swig", \
    \n        "wget" \
    \n      ] \
    \n    ], \
    \n    [ \
    \n      "add_to_entrypoint", \
    \n      "source /etc/fsl/fsl.sh" \
    \n    ], \
    \n    [ \
    \n      "user", \
    \n      "neuro" \
    \n    ], \
    \n    [ \
    \n      "miniconda", \
    \n      { \
    \n        "conda_install": [ \
    \n          "python=3.6", \
    \n          "pytest", \
    \n          "jupyter", \
    \n          "jupyterlab", \
    \n          "jupyter_contrib_nbextensions", \
    \n          "traits", \
    \n          "pandas", \
    \n          "matplotlib", \
    \n          "scikit-learn", \
    \n          "scikit-image", \
    \n          "seaborn", \
    \n          "nbformat", \
    \n          "nb_conda" \
    \n        ], \
    \n        "pip_install": [ \
    \n          "https://github.com/nipy/nipype/tarball/master", \
    \n          "https://github.com/INCF/pybids/tarball/master", \
    \n          "nilearn", \
    \n          "nibabel", \
    \n          "nipy", \
    \n          "duecredit", \
    \n          "nbval", \
    \n          "pymvpa2", \
    \n          "keras", \
    \n          "tensorflow", \
    \n          "pybids" \
    \n        ], \
    \n        "create_env": "neuro", \
    \n        "activate": true \
    \n      } \
    \n    ], \
    \n    [ \
    \n      "run_bash", \
    \n      "source activate neuro && jupyter nbextension enable exercise2/main && jupyter nbextension enable spellchecker/main" \
    \n    ], \
    \n    [ \
    \n      "user", \
    \n      "root" \
    \n    ], \
    \n    [ \
    \n      "run", \
    \n      "mkdir /data && chmod 777 /data && chmod a+s /data" \
    \n    ], \
    \n    [ \
    \n      "run", \
    \n      "mkdir /output && chmod 777 /output && chmod a+s /output" \
    \n    ], \
    \n    [ \
    \n      "run", \
    \n      "mkdir /templates && chmod 777 /templates && chmod a+s /templates" \
    \n    ], \
    \n    [ \
    \n      "run", \
    \n      "rm -rf /opt/conda/pkgs/*" \
    \n    ], \
    \n    [ \
    \n      "user", \
    \n      "neuro" \
    \n    ], \
    \n    [ \
    \n      "run", \
    \n      "curl -L -o /data/dataset.zip https://www.dropbox.com/s/4k4npu7wsz1rtwk/dataset.zip?dl=1 && unzip /data/dataset.zip -d /data/ && rm /data/dataset.zip" \
    \n    ], \
    \n    [ \
    \n      "run", \
    \n      "curl -L -o /output/datasink.zip https://www.dropbox.com/s/torun2z8vchyhsd/datasink.zip?dl=1 && unzip /output/datasink.zip -d /output/ && rm /output/datasink.zip" \
    \n    ], \
    \n    [ \
    \n      "copy", \
    \n      [ \
    \n        "templates", \
    \n        "/templates" \
    \n      ] \
    \n    ], \
    \n    [ \
    \n      "copy", \
    \n      [ \
    \n        "notebooks", \
    \n        "/home/neuro/notebooks" \
    \n      ] \
    \n    ], \
    \n    [ \
    \n      "copy", \
    \n      [ \
    \n        "slides", \
    \n        "/home/neuro/slides" \
    \n      ] \
    \n    ], \
    \n    [ \
    \n      "copy", \
    \n      [ \
    \n        "program.ipynb", \
    \n        "/home/neuro/program.ipynb" \
    \n      ] \
    \n    ], \
    \n    [ \
    \n      "copy", \
    \n      [ \
    \n        "test_notebooks.py", \
    \n        "/home/neuro/test_notebooks.py" \
    \n      ] \
    \n    ], \
    \n    [ \
    \n      "run", \
    \n      "mkdir -p ~/.jupyter && echo c.NotebookApp.ip = \\\"0.0.0.0\\\" > ~/.jupyter/jupyter_notebook_config.py" \
    \n    ], \
    \n    [ \
    \n      "workdir", \
    \n      "/home/neuro" \
    \n    ], \
    \n    [ \
    \n      "user", \
    \n      "root" \
    \n    ], \
    \n    [ \
    \n      "run", \
    \n      "chown -R neuro /home/neuro" \
    \n    ], \
    \n    [ \
    \n      "user", \
    \n      "neuro" \
    \n    ], \
    \n    [ \
    \n      "cmd", \
    \n      [ \
    \n        "jupyter-notebook" \
    \n      ] \
    \n    ] \
    \n  ] \
    \n}' > /neurodocker/neurodocker_specs.json
