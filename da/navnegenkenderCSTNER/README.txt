
--------------------------------------------------------------------------------
                        CstNER                      
--------------------------------------------------------------------------------
Version: V4.0
Licence: CLARIN_ACA-NC (Clarin academic licens for non-commercial use)
IPR-holder: University of Copenhagen

17-12 2012
Dorte Haltrup Hansen

------------
DESCRIPTION:
------------
CSTner is a rule based language dependent named entity recognizer (NER) for Danish.
It is implemented in perl and runs om linux with utf8 input and output.

NEs are here characterized by starting with uppercase. Interpunctation araound
uppercase tokens is ignored, the uppercase tokens are looked up in external lists (see files),
and token internal and token external clues are used to clasity the names. 
Frequent sentence initial words, frequent listed "no-names" and uppercase tokens
that exist in a lowercase version elsewhere in the document are ignored.
Tokens are concatenated if person or company names.

The user can add their own sentence initial words to the file: "Berl.initord" 
and their own "no-names" to the file "nonames".

At the end of the programme the user can chage the output using '#' 
to include/exclude output mode.
 print "$tok";                                     # Print all
 #if($tok =~ /<NE cat=\"/){print "$tok\n"}         # Print only NE tags
 #print "\n";                                      # One token a line


-----------
RUN CstNER:
-----------
Input file: text(utf8) 
Outptu file: txt(utf8) with tags (<NE cat="abcd" certain="7">Named Entity</NE>)

Syntax:
perl CstNER.pl INPUTFILE > OUTPUTFILE
Must be run in the same directory as the external name lists.




-----------
NER CATEGORIES:
-----------
person
street
city
country
place
organisation
misc (other)

E.g.
<NE cat="person" certain="1">Antonio Natale</NE>
<NE cat="street" certain="1">Lindhagensgatan</NE>
<NE cat="city" certain="1">Warszawa</NE>
<NE cat="country" certain="1">Danmark</NE>
<NE cat="place" certain="1">Asien</NE>
<NE cat="organisation" certain="1">Arla Foods amba</NE>
<NE cat="misc" certain="3">Telefax</NE> 


-----------
CERTAINTY TAGS:
---------------
The certainty tags indicates if a named entity is found on a list (certainty = 1),
if part of the name is found on a list or if clues indicates the category (certainty = 2),
or if the category is uncertain (certainty = 3).
Then <NE cat="misc" certain="3"> is probably not a name, but can be.

E.g.
<NE cat="person" certain="1">Lene Stampe Thomsen</NE> (all names are on the lists))
<NE cat="person" certain="2">Iver Huifeldt</NE> (only Iver is on the firstname list)
<NE cat="misc" certain="3">Nato</NE>  (Nato is unknown - but is a name)
<NE cat="misc" certain="3">Rederi</NE> (Rederi is unknown - but is a not name)




------
FILES (lists of names):
------
   1391 Berl.initord  (frequent sentenceinitial word for the newspaper Berlingske Tidende)
     43 company (company abb.)
    281 contrynames
    584 DKcity (Danish city names)
  10328 firstnames
     72 islandnames
    333 miscplace (other place names)
   1531 nonames (upper case word that are not names)
    977 nonDKcity (cities outside Denmark)
     20 street
  94639 surnames


-------------
CONTACT INFO:
-------------
For questions and remarks about the program, please feel free to contact us.

Our postal address is:

Center for Sprogteknologi
University of Copenhagen
Njalsgade 140
2300 Copenhagen S.
Denmark
