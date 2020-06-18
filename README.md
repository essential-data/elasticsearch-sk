Slovenská podpora pre ElasticSearch
===================================

Autorské práva
--------------

Copyright (c) 2015 Essential Data, s.r.o.

Toto dielo je možné používať v súlade s textami nasledujúcich licencií:

* GNU Affero General Public License, verzia 3
* Creative Commons Attribution-ShareAlike 4.0 International
* GNU Free Documentation License 1.3

Viac informácií v súbore LICENSE. 

*Pozor!* Tieto slovníky sú publikované pod inou licenciou ako slovníky z projektu sk-spell!

Zaujíma vás práca s jazykom? Pracujte pre nás!
----------------------------------------------

Essential Data pracuje s jazykom, s dátami a na zaujímavých projektoch. Pozrite si
[aktuálne otvorené pozície](http://www.essential-data.sk/pracujte-pre-nas/) a pracujte v skvelom
tíme plnom šikovných ľudí.

Inštalácia - cez Docker
-----------------------

Najjednoduchší spôsob ako vyskúšať a začať okamžite pracovať so slovenskou podporou pre Elastic Search je nainštalovať ho do [Docker-u](https://www.docker.com/) priamo z Docker Hub repozitára:

	docker pull essentialdata/elasticsearch-sk
	docker run -d -p 9200:9200 -p 9300:9300 essentialdata/elasticsearch-sk

Druhá možnosť je použiť priložený Dockerfile (vhodné ak ho chcete zmeniť):

	cd elasticsearch-sk
	docker build -t essentialdata/elasticsearch-sk .
	docker run -d -p 9200:9200 -p 9300:9300 essentialdata/elasticsearch-sk

Inštalácia - do existujúcej inštancie ElasticSearch
---------------------------------------------

Stiahnite aktuálny slovník (s ASCII folding alebo bez ASCII folding) z oficiálnej stránky [Essential Data hunspell slovníka](https://github.com/essential-data/hunspell-sk/releases/latest).

Rozbaľte ho do adresára elasticsearch/config/hunspell/sk_SK tak, aby sa v tomto adresári už priamo nachádzali slovníkové súbory.

Pridajte konfiguračný súbor z adresára config do toho istého adresára.

Konfigurácia
------------

Najprv si pripravme pôdu, aby sa nám s ElasticSearch lepšie pracovalo - nastavme si URL pre ElasticSearch a vytvorme príkazy GET, POST a pod., ktoré budeme používať. 

    for method in GET HEAD POST PUT DELETE TRACE OPTIONS; do
      alias "$method"="lwp-request -m '$method'"
    done
    
    # zmenit na URL Elastic Search
    ELASTIC_URL="http://192.168.59.103:9200"
    # prípadne pri inštalácii na lokálnom serveri inak ako cez boot2docker:
    #ELASTIC_URL="http://127.0.0.1:9200"
    

Pri príkazoch PUT, ktoré očakávajú štandardný vstup môžeme vložiť celý príkaz naraz, ale treba si dať pozor, aby EOF bolo na začiatku riadku (ak to vkladáte zo zdrojového README.md, nie z webovej verzie, budete mať EOF odsadený zľava štyrmi medzerami - v takomto prípade nevkladajte EOF, ale ho napíšte ručne bez úvodných medzier).

Vytvoríme index s názvom my_index, ktorý bude mať nový analyzer ```sk_SK```:


    PUT ${ELASTIC_URL}/my_index < examples/create_my_index-asciifolding

Vyskúšajme tento analyzer:

    echo 'maslá' | POST ${ELASTIC_URL}/my_index/_analyze?analyzer=sk_SK

Vytvorme mapovanie ```tests```, ktoré bude používať na políčko text slovenský analyzér:

    PUT ${ELASTIC_URL}/my_index/_mapping/tests << EOF
    {
        "tests": {
            "properties": {
                "text": {
                    "type":     "string",
                    "analyzer": "sk_SK"
                }
            }
        }
    }
    EOF

Vyskúšajme pridať testovacie dáta a otestujeme vyhľadávanie:

    PUT ${ELASTIC_URL}/my_index/tests/test1 << EOF
    {
    "text": "kto vie či v tomto texte sa môže písať aj o maslách"
    }
    EOF
    
    PUT ${ELASTIC_URL}/my_index/tests/test2 << EOF
    {
    "text": "ej veru aj šunka alebo pečienka je dobrá hovädzinka"
    }
    EOF
    
    GET ${ELASTIC_URL}/my_index/tests/_search?q=text:šunky


Verzia bez ASCII foldingu
-------------------------

Ak by ste radšej používali verziu bez ASCII foldingu, použite slovník s diakritikou
(pozrite do ```Dockerfile``` ako na to) a nastavuje sa takto:

    PUT ${ELASTIC_URL}/my_index < examples/create_my_index

Odkazy
------

* [Github spoločnosti Essential Data](https://github.com/essential-data/) - obsahuje naše open-source projekty (aj) pre prácu s jazykom
* [Projekt Hunspell-sk](https://github.com/essential-data/hunspell-sk) od Essential Data, z ktorého používame slovník.
* [Docker Hub stránka tohto projektu](https://registry.hub.docker.com/r/essentialdata/elasticsearch-sk)
* [Github tohto projektu](https://github.com/essential-data/elasticsearch-sk)
