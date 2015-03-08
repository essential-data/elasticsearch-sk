FROM dockerfile/elasticsearch
MAINTAINER Juraj Bednar <bednar@essential-data.sk>

ENV HUNSPELL_SK_BASE https://github.com/essential-data/hunspell-sk/releases/download/1.1/
# Version with ASCII folding:
ENV HUNSPELL_SK_FILE hunspell-sk_SK-lemma-ascii.tar.gz
# Version without ASCII folding:
#ENV HUNSPELL_SK_FILE hunspell-sk_SK-lemma.tar.gz

ADD config/settings.yml /elasticsearch/config/hunspell/sk_SK/settings.yml
ADD ${HUNSPELL_SK_BASE}/${HUNSPELL_SK_FILE} /elasticsearch/config/hunspell/
RUN cd /elasticsearch/config/hunspell/sk_SK && \
         tar xvzf ../${HUNSPELL_SK_FILE} --strip-components=1 && \
         rm -f ../${HUNSPELL_SK_FILE}

