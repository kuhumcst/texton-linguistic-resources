#!/usr/bin/perl 

use open ':utf8';
use open ':std';
use utf8;
use IO::Handle;

#	 Frq no-names
open (IGNORE,"nonames") || die "Cannot open: nonames";
$count = "0";
while(<IGNORE>) {
    @toks = split;
    if($count eq "0") {
        $toks[0] =~ s/﻿//;
        $count++;
    }    
    $ignore{"$toks[0]"} = 1;
} end while
close (IGNORE);

open (FNAME,"firstnames") || die "Cannot open: firstnames";
while(<FNAME>) {
    @toks = split;
    $fname{"$toks[0]"} = 1;
} end while
close (FNAME);

open (SNAME,"surnames") || die "Cannot open: surnames";
while(<SNAME>) {
    @toks = split;
    $sname{"$toks[0]"} = 1; 
} end while
close (SNAME);

open (CITY,"DKcity") || die "Cannot open: DKcity";
while(<CITY>) {
    @toks = split;
    $DKcity{"$toks[0]"} = 1;
} end while
close (CITY);

open (CITY,"nonDKcity") || die "Cannot open: nonDKcity";
while(<CITY>) {
    @toks = split;
    $nonDKcity{"$toks[0]"} = 1;
} end while
close (CITY);

open (COUNTRY,"countrynames") || die "Cannot open:  contrynames";
while(<COUNTRY>) {
    @toks = split;
    $country{"$toks[0]"} = 1;
} end while
close (COUNTRY);

open (ISLAND,"islandnames") || die "Cannot open:  islandnames";
while(<ISLAND>) {
    @toks = split;
    $island{"$toks[0]"} = 1;
} end while
close (ISLAND);

open (PLACE,"miscplace") || die "Cannot open: miscplace";
while(<PLACE>) {
    @toks = split;
    $place{"$toks[0]"} = 1;
} end while
close (PLACE);

open (COMP,"company") || die "Cannot open: company";
while(<COMP>) {
    @toks = split;
    $company{"$toks[0]"} = 1;
} end while
close (COMP);

open (STREET,"street") || die "Cannot open: street";
while(<STREET>) {
    @toks = split;
    $street{"$toks[0]"} = 1;
} end while
close (STREET);

open (ORG,"organisation") || die "Cannot open: organisation";
while(<ORG>) {
    @toks = split;
    $org{"$toks[0]"} = 1;
} end while
close (ORG);


#-------------------------------------------------------------------------------
#   Read in file, put in array
#-------------------------------------------------------------------------------
    
$nr = "0";
$linenr = "0";
while ($line = <>) {
  @toks = split(/ /,$line);   
	for($i=0; $i < @toks; $i++) {
          $in_document{"@toks[$i]"} = 1;
          $document_words[$nr]= "@toks[$i]";
          $nr++;          
	}
	$document_lines[$linenr] = $line;
	$linenr++;
} 


#-------------------------------------------------------------------------------
#	Put tags on uppercase words
#-------------------------------------------------------------------------------

$flag = "stop";
foreach $linie(@document_lines){
  $linie  =~ s/\/(\p{Lu}+\p{Ll}+)/\/ $1/;     


                        
#--- Sentence initial words
  $linie =~ s/^([\"\”\'\(\[])([\p{Lu}]+[\p{L}\d\-\/\&\/]*)/$1 $2\/\*INIT\*/g;  		
  $linie =~ s/^([\p{Lu}]+[\p{L}\d\-\/\&\/\.\'\´]*)([\"\”\)\]\,\:\!\?]+)/$1 $2/g;	
  $linie =~ s/^([\p{Lu}]+[\p{L}\d\-\/\&\/]*)([\s\t\'\´\.]+)/$1\/\*INIT\*$2/g;
  $linie =~ s/^(\d+[\.\)][\s\t]+)([\p{Lu}]+[\p{L}\d\-\/\&\/]*)/$1$2\/\*INIT\*/g; 
  $linie =~ s/^([\-\•]+)([\p{Lu}]+[\p{L}\d\-\/\&\/]*)/$1 $2\/\*INIT\*/g;


#--- Paragraph initial words -> NAME_INIT
  $linie =~ s/([\:\.][\s\t]+)([\p{Lu}]+[\p{L}\d\-\&]*)/$1$2\/\*INIT\*/g;

#--- Other uppercase NAME_CAND
  $linie =~ s/([\"\”\'\(\[])(\p{Lu})/$1 $2/g;                                 
  $linie =~ s/([\p{Lu}]+[\p{L}\d\-\&\.\'\´]*)([\"\”\)\]\,\;\:\!\?]+)/$1 $2/g;	
  $linie =~ s/([\p{Lu}]+[\p{L}\d\-\&]*)([\s\t\'\´\.]+)/$1\/NAME_CAND$2/g;  	
                                                                            

# -- \d\-\&\.\w -> i NAME_CAND last
  $linie =~ s/(\/NAME_CAND)([\p{L}\d\-\&\.]+)([\p{L}\d\-\&\.]+)/$2$3/g;
  $linie =~ s/(\/\*INIT\*)([\p{L}\d\-\&\.]+)([\p{L}\d\-\&\.]+)/$2$3/g;

# ---  *INIT* -> NAME_INIT
  $linie =~ s/\*INIT\*/NAME_INIT/g;
  $linie =~ s/NAME_INIT\/NAME_INIT/NAME_INIT/g;

#--- X. -> NAME_SING
  $linie =~ s/[\s\t](\p{Lu})[\/NAMEINITCAND\_]+\./ $1\.\/NAME_SING/g;
  $linie =~ s/^(\p{Lu})[\/NAMEINITCAND\_]+\./ $1\.\/NAME_SING/g;

  
# --- Street no.
  $linie  =~ s/(\d+) ([A-Z])\/NAME_CAND \, ([st\.\d]*) ([Tt]h\.*)/$1\=$2\=\,\=$3\=$4\/gadenr/g;
  $linie  =~ s/(\d+) ([A-Z])\/NAME_CAND\, ([st\.\d]*) ([Tt]h\.*)/$1\=$2\,\=$3\=$4\/STREETNO/g;
  $linie  =~ s/(\d+[A-Z])\/NAME_CAND \, ([st\.\d]*) ([Tt]h\.*)/$1\=\,\=$2\=$3\/STREETNO/g;
  $linie  =~ s/(\d+[A-Z])\/NAME_CAND\, ([st\.\d]*) ([Tt]h\.*)/$1\,\=$2\=$3\/STREETNO/g;
  $linie  =~ s/(\d+) \, ([st\.\d]*) ([Tt]h\.*)/$1\=\,\=$2\=$3\/STREETNO/g;  
  $linie  =~ s/(\d+)\, ([st\.\d]*) ([Tt]h\.*)/$1\,\=$2\=$3\/STREETNO/g; 
  $linie  =~ s/(\d+) ([st\.\d]*) ([Tt]h\.*)/$1\=$2\=$3\/STREETNO/g; 
 
#-------------------------------------------------------------------------------
#  Split in tokens
#-------------------------------------------------------------------------------
  $linie =~ s/\r/\*SPLIT\*\*r\*\*SPLIT\*/g;
  $linie =~ s/\n/\*SPLIT\*\*n\*\*SPLIT\*/g;
  $linie =~ s/\t/\*SPLIT\*\*t\*\*SPLIT\*/g;
  $linie =~ s/ /\*SPLIT\*\*s\*\*SPLIT\*/g;
  @toks = split(/\*SPLIT\*/,$linie);
  $linie = "";
  
#-------------------------------------------------------------------------------
#  Check each token
#-------------------------------------------------------------------------------


for($i=0; $i < @toks; $i++) {
  unless(@toks[$i] =~ /\*[nrst]\*/){      
    $tmp = @toks[$i];
    $tmp =~ s/(.+)(\/NAME_INIT).*/$1/g;  
    $tmp =~ s/(.+)(\/NAME_CAND).*/$1/g;   
    if(@toks[$i] =~ /\.$/){               
      $tmp2 = "$tmp\.";
    }
    else{
      $tmp2 = "$tmp";
    }
    $lc_tmp = "\l$tmp";                 
    
    unless(@toks[$i] =~ /^\p{Lu}/){        
       @toks[$i] =~ s/\/NAME_[INITCAND]+//g;
    }
    @toks[$i] =~ s/\=/ /g;               
    
#-------------------------------------------------------------------------------
#	  NO NAMES (ignore list or in document)
#-------------------------------------------------------------------------------

  if(@toks[$i] =~ /NAME_INIT/){
    if($in_document{"$lc_tmp"}){   
         @toks[$i] =~ s/([\p{Lu}]+[\p{L}\d\-\&\/\/]*)\/NAME_INIT/$1\/NO_NAME_INIT/g;
         @toks[$i] =~ s/Hans\/NO_NAME_INIT/Hans\/NAME_INIT/;
     } 
  } 

  if($ignore{"$tmp"}){
         @toks[$i] =~ s/([\p{Lu}]+[\p{L}\d\-\/\&\/]*)\/NAME_INIT/$1\/IGNORE_NAME_INIT/g;
         @toks[$i] =~ s/([\p{Lu}]+[\p{L}\d\-\/\&\/]*)\/NAME_CAND/$1\/IGNORE_NAME_CAND/g;
  }  
#-------------------------------------------------------------------------------
#	  STREET DESIGNATORS
#-------------------------------------------------------------------------------

   if($street{"$tmp"}){
        @toks[$i] =~ s/(.+)/$1\/NAME_VEJ/;
        @toks[$i] =~ s/\/NAME_INIT//;
        @toks[$i] =~ s/\/NAME_CAND//; 
    } 

#-------------------------------------------------------------------------------
#	 COMPANY DESIGNATORS
#-------------------------------------------------------------------------------
      $oldtmp = $tmp;
      $tmp =~ s/s$//;
    if($company{"$tmp"}){
        @toks[$i] =~ s/(.+)/$1\/COMP/;
        @toks[$i] =~ s/\/NAME_INIT//;
        @toks[$i] =~ s/\/NAME_CAND//; 
    } 
    elsif($company{"$tmp2"}){
        @toks[$i] =~ s/(.+)/$1\/COMP/;;
        @toks[$i] =~ s/\/NAME_INIT//;
        @toks[$i] =~ s/\/NAME_CAND//; 
      }  
      else{
        $tmp = $oldtmp;
      }
 
#-------------------------------------------------------------------------------
#	LISTS OF NAMES
#-------------------------------------------------------------------------------
  if(@toks[$i]=~ /\/NAME/){
#--- PERS_NAME = FNAME or SNAME
    if($fname{"$tmp"}){
          @toks[$i] =~ s/([\p{Lu}]+[\p{L}\d\-\'\.\/\&\/]+)(\/NAME_[INITCAND]+)/$1\/NAME_PERS_FIRST/g;
    }
    elsif($sname{"$tmp"}){
          @toks[$i] =~ s/([\p{Lu}]+[\p{L}\d\-\'\.\/\&\/]+)(\/NAME_[INITCAND]+)/$1\/NAME_PERS_LAST/g;
    }
#--- CITY_NAME_DK
    elsif($DKcity{"$tmp"}){
          @toks[$i] =~ s/([\p{Lu}]+[\p{L}\d\-\'\.\/\&\/]+)(\/NAME_[INITCAND]+)/$1\/NAME_CITY_DK/g;
    }
#--- CITY_NAME_UL 
    elsif($nonDKcity{"$tmp"}){
          @toks[$i] =~ s/([\p{Lu}]+[\p{L}\d\-\'\.\/\&\/]+)(\/NAME_[INITCAND]+)/$1\/NAME_CITY_UL/g;
    }
#--- COUNTRY_NAME
    elsif($country{"$tmp"}){
          @toks[$i] =~ s/([\p{Lu}]+[\p{L}\d\-\'\.\/\&\/]+)(\/NAME_[INITCAND]+)/$1\/NAME_COUNTRY/g;
    }
#---PLACE_NAME 
    elsif($place{"$tmp"}){
          @toks[$i] =~ s/([\p{Lu}]+[\p{L}\d\-\'\.\/\&\/]+)(\/NAME_[INITCAND]+)/$1\/NAME_PLACE/g;
    }
#--- ISLAND
      elsif($island{"$tmp"}){
           @toks[$i] =~ s/([\p{Lu}]+[\p{L}\d\-\'\.\/\&\/]+)(\/NAME_[INITCAND]+)/$1\/NAME_ISLAND/g;
      }
#--- ORG NAME
      elsif($org{"$tmp"}){
           @toks[$i] =~ s/([\p{Lu}]+[\p{L}\d\-\'\.\/\&\/]+)(\/NAME_[INITCAND]+)/$1\/NAME_ORG/g;
      }

#-------------------------------------------------------------------------------
# Without final -s
#-------------------------------------------------------------------------------

    elsif($tmp =~ /s$/){
      $oldtmp = $tmp;
      $tmp =~ s/s$//;
#--- PERS_NAME = FNAME or SNAME
    if($fname{"$tmp"}){
          @toks[$i] =~ s/([\p{Lu}]+[\p{L}\d\-\'\.\/\&\/]+)(\/NAME_[INITCAND]+)/$1\/NAME_PERS_FIRST/g;
    }
    elsif($sname{"$tmp"}){
          @toks[$i] =~ s/([\p{Lu}]+[\p{L}\d\-\'\.\/\&\/]+)(\/NAME_[INITCAND]+)/$1\/NAME_PERS_LAST/g;
    }
#--- CITY_NAME_DK
    elsif($DKcity{"$tmp"}){
          @toks[$i] =~ s/([\p{Lu}]+[\p{L}\d\-\'\.\/\&\/]+)(\/NAME_[INITCAND]+)/$1\/NAME_CITY_DK/g;
    }
#--- CITY_NAME_UL 
    elsif($nonDKcity{"$tmp"}){
          @toks[$i] =~ s/([\p{Lu}]+[\p{L}\d\-\'\.\/\&\/]+)(\/NAME_[INITCAND]+)/$1\/NAME_CITY_UL/g;
    }
#--- COUNTRY_NAME
    elsif($country{"$tmp"}){
          @toks[$i] =~ s/([\p{Lu}]+[\p{L}\d\-\'\.\/\&\/]+)(\/NAME_[INITCAND]+)/$1\/NAME_COUNTRY/g;
    }
#---PLACE_NAME 
    elsif($miscplace{"$tmp"}){
          @toks[$i] =~ s/([\p{Lu}]+[\p{L}\d\-\'\.\/\&\/]+)(\/NAME_[INITCAND]+)/$1\/NAME_PLACE/g;
    }
#--- ISLAND
      elsif($island{"$tmp"}){
           @toks[$i] =~ s/([\p{Lu}]+[\p{L}\d\-\'\.\/\&\/]+)(\/NAME_[INITCAND]+)/$1\/NAME_ISLAND/g;
      }
#--- ORG
      elsif($org{"$tmp"}){
           @toks[$i] =~ s/([\p{Lu}]+[\p{L}\d\-\'\.\/\&\/]+)(\/NAME_[INITCAND]+)/$1\/NAME_ORG/g;
      }
      else{
        $tmp = $oldtmp;
      }
    }

   } 

#--- MISC_NAME if not on lists
    @toks[$i] =~ s/\/IGNORE_NAME_INIT//g;
    @toks[$i] =~ s/\/IGNORE_NAME_CAND//g;
    @toks[$i] =~ s/\/NO_NAME_INIT//g;
    @toks[$i] =~ s/NAME_INIT/NAME_MISC_INIT/g;
    @toks[$i] =~ s/NAME_CAND/NAME_MISC/g;
    
#------------------------------------------------------------------------ 
#	Unite tokens with name  tags
#------------------------------------------------------------------------   


    if(@toks[$i] =~ /\/COMP/){		
      if(@toks[$i-2] =~ /^\&amp\;$/){		
         @toks[$i] =~ s/\/COMP/\/NAME_COMP/g;
      }
      elsif(@toks[$i-2] =~ /\/NAME/){
          @toks[$i] =~ s/\/COMP//g;
          @toks[$i-2] =~ s/\/NAME[A-Z\_\/]+//g;      
          @toks[$i-2] =~ s///;
          @toks[$i] = "@toks[$i-2] @toks[$i]\/NAME_COMP";
          @toks[$i-2] = "";
      }
      elsif((@toks[$i-4] =~ /\/NAME/)&&(@toks[$i-2] =~ /\,/)){
         @toks[$i-4] =~ s/\/NAME[A-Z\_\/]+/\/NAME_COMP/g;
         @toks[$i] =~ s/\/COMP//g;
      }

      else{
        @toks[$i] =~ s/\/COMP//g;
      }
    } 

 
   if(@toks[$i] =~ /^[A-ZÆØÅ]+[\-\d\wA-ZÆØÅ]+\/NAME_MISC$/){	
        if(@toks[$i-2] =~ /[Ff]orhold/){
          @toks[$i] =~ s/\/NAME_MISC//g;  
        }    
    }
  
    if(@toks[$i] =~ /\/NAME\_[A-Z\_]+/){   
      if(($i > 1)&& (@toks[$i-2] =~ /\/NAME\_[A-Z\_]+$/)){ 			
        @toks[$i] = "@toks[$i-2] @toks[$i]";
        @toks[$i] =~ s/(.+)(\/NAME[A-Z\_]+) (.+)(\/NAME.+)/$1 $3$2$4/g; 
        @toks[$i] =~ s/(\/NAME_COMP)(\/NAME_[\_A-Z\/]*)/$1/g;
        @toks[$i] =~ s/NAME_SING\/NAME_MISC[\_INT]*/NAME_PERS_MAYBE/g; 
        @toks[$i] =~ s/(\/NAME_PERS_MAYBE)(\/NAME_PERS)_LAST/$2/g;
        @toks[$i] =~ s/(\/NAME_PERS_FIRST)(\/NAME_SING)/$2/g;    
        @toks[$i] =~ s/(\/NAME_SING)(\/NAME_PERS)_LAST/$2/g;
        @toks[$i] =~ s/(\/NAME_PERS_FIRST)\/NAME_PERS_FIRST/$1/g;    
        @toks[$i] =~ s/(\/NAME_PERS)_FIRST\/NAME_PERS_LAST/$1/g;
        @toks[$i] =~ s/(\/NAME_PERS)\/NAME_PERS_LAST/$1/g;
        @toks[$i] =~ s/(\/NAME_PERS)_LAST\/NAME_PERS_LAST/$1/g;
        @toks[$i] =~ s/(\/NAME_MISC)[INT\_]*\/NAME_MISC/$1/g;
        @toks[$i] =~ s/(\/NAME_CITY[A-Z\_]+)\/NAME_SING/$1/g;
        @toks[$i] =~ s/\/NAME_.+(\/NAME_COMP)/$1/g;
        @toks[$i] =~ s/(\/NAME_VEJ)(\/NAME_[\_A-Z\/]*)/\/NAME_STREET/g;
        @toks[$i] =~ s/\/NAME_[A-Z\_]+\/NAME_VEJ/\/NAME_STREET/g;
        @toks[$i] =~ s/(\/NAME_PERS_FIRST)\/NAME_MISC[INT\_]*/$1/g;
        @toks[$i] =~ s/\/NAME_MISC[INT\_]*(\/NAME_PERS_LAST)/$1/g;
        @toks[$i] =~ s/\/NAME_COUNTRY(\/NAME_COUNTRY)/$1/g;
        @toks[$i] =~ s/\/NAME_COUNTRY(\/NAME_COUNTRY)/$1/g;
        @toks[$i] =~ s/\/NAME_MISC\/NAME_STREET(\/NAME_INSTANS)/$1/g;
        @toks[$i] =~ s/\/NAME_MISC(\/NAME_INSTANS)/$1/g;
        @toks[$i] =~ s/(\/NAME_INSTANS)\/NAME_MISC/$1/g;
        @toks[$i] =~ s/\/NAME_CITY[\_DKUL]+(\/NAME_CITY[\_DKUL]+)/$1/g;
        @toks[$i] =~ s/\/NAME_MISC[\_INIT]*(\/NAME_CITY[\_DKUL]+)/$1/g;
        @toks[$i-2]  ="";
        @toks[$i-1]  ="";
      } 

#------------------------------------------------------------------------ 
#	      Look at the preceding word
#------------------------------------------------------------------------   

      elsif((@toks[$i-2] =~ /&amp;/) && (@toks[$i-4] =~  /\/NAME\_[A-Z\_]+/)){	
        @toks[$i] = "@toks[$i-4] @toks[$i-2] @toks[$i]";
        @toks[$i] =~ s/\/NAME_[A-Z\_\/]+ &amp; / &amp; /g;
        @toks[$i-1]  ="";
        @toks[$i-2]  ="";
        @toks[$i-3]  ="";
        @toks[$i-4]  ="";
      } # elsif -2 = &amp;
      elsif((@toks[$i-2] =~ /^\&$/) && (@toks[$i-4] =~  /\/NAME\_[A-Z\_]+/)){	
        @toks[$i] = "@toks[$i-4] @toks[$i-2] @toks[$i]";
        @toks[$i] =~ s/\/NAME_[A-Z\_\/]+ \& / \& /g;
        @toks[$i-1]  ="";
        @toks[$i-2]  ="";
        @toks[$i-3]  ="";
        @toks[$i-4]  ="";
      } # elsif -2 = &

      elsif((@toks[$i-2] =~ /^og$/)&&(@toks[$i-4] =~ /\-\/NAME/)){		
        @toks[$i] = "@toks[$i-4] og @toks[$i]";
        @toks[$i] =~ s/(.+)(\/NAME[\_A-Z]+) og (.+)(\/NAME[\_A-Z]+)/$1 og $3$2$4/g;
        @toks[$i-1]  ="";
        @toks[$i-2]  ="";
        @toks[$i-3]  ="";
        @toks[$i-4]  ="";
      }
       elsif((@toks[$i-2] =~ /^of$/)&&(@toks[$i-4] =~ /\/NAME/)){		
        @toks[$i] = "@toks[$i-4] of @toks[$i]";
        @toks[$i] =~ s/(.+)(\/NAME[\_A-Z]+) of (.+)(\/NAME[\_A-Z]+)/$1 of $3$2$4/g;
        @toks[$i-1]  ="";
        @toks[$i-2]  ="";
        @toks[$i-3]  ="";
        @toks[$i-4]  ="";
      }
      elsif(@toks[$i-2] =~ /De[nt]?/){
        @toks[$i] = "@toks[$i-2] @toks[$i]";
        @toks[$i-1]  ="";
        @toks[$i-2]  ="";
      }
#------------------------------------------------------------------------ 
#	 Look on the subsequent words
#------------------------------------------------------------------------   
    
      if(
        (@toks[$i] =~ /\-$/)&& 
        (@toks[$i+2] =~ /^og$/) && 
        (@toks[$i+4]=~ /^\p{Ll}/)){       
        @toks[$i] =~ s/\/NAME[\_A-Z]+//;
      }


#------------------------------------------------------------------------ 
#   Name internal clues
#------------------------------------------------------------------------ 
    @toks[$i] =~ s/(gade[s]*)\/NAME.+/$1\/NAME_STREET/;
    @toks[$i] =~ s/(vej[ens]*)\/NAME[\_A-Z]+/$1\/NAME_STREET/;
    @toks[$i] =~ s/([Ss]træde[s]*)\/NAME[\_A-Z]+/$1\/NAME_STREET/;
    @toks[$i] =~ s/(torvet)\/NAME[\_A-Z]+/$1\/NAME_STREET/;
    @toks[$i] =~ s/([Pp]lads)\/NAME[\_A-Z]+/$1\/NAME_STREET/;
    @toks[$i] =~ s/(vænge[ts]*)\/NAME[\_A-Z]+/$1\/NAME_STREET/;
    @toks[$i] =~ s/(vangen[s]*)\/NAME[\_A-Z]+/$1\/NAME_STREET/;
    @toks[$i] =~ s/(svinget[s]*)\/NAME[\_A-Z]+/$1\/NAME_STREET/;
    @toks[$i] =~ s/(toften[s]*)\/NAME[\_A-Z]+/$1\/NAME_STREET/;
    @toks[$i] =~ s/(led[det]*)\/NAME.+/$1\/NAME_STREET/;
    @toks[$i] =~ s/(gatan[s]*)\/NAME[\_A-Z]+/$1\/NAME_STREET/;


    @toks[$i] =~ s/([Ss]parekasse[ns]*)\/NAME[\_A-Z]+/$1\/NAME_COMP/;
    @toks[$i] =~ s/([Bb]ank[ens]*)\/NAME[\_A-Z]+/$1\/NAME_COMP/;
    @toks[$i] =~ s/(Pengeinstitut[tets]*)\/NAME[\_A-Z]+/$1\/NAME_COMP/;	     
    @toks[$i] =~ s/([Ff]irma[et]*)\/NAME[\_A-Z]+/$1\/NAME_COMP/g;
    @toks[$i] =~ s/([Vv]irksomhed[en]*)\/NAME[\_A-Z]+/$1\/NAME_COMP/;
    @toks[$i] =~ s/([Ff]abrik[ken]*)\/NAME[\_A-Z]+/$1\/NAME_COMP/;
    @toks[$i] =~ s/([Rr]estaurant)\/NAME[\_A-Z]+/$1\/NAME_COMP/;
    @toks[$i] =~ s/([Cc]af[ée])\/NAME[\_A-Z]+/$1\/NAME_COMP/;
    @toks[$i] =~ s/([Pp]izzeria)\/NAME[\_A-Z]+/$1\/NAME_COMP/;
                
    } # if NAME

#------------------------------------------------------------------------ 
#	ADRESSES
#------------------------------------------------------------------------ 
   if( @toks[$i] =~/NAME_STREET/){
      if(@toks[$i+2] =~ /\/STREETNO/){			
         @toks[$i] = "@toks[$i] @toks[$i+2]";
         @toks[$i] =~ s/\/STREETNO//g;
         @toks[$i] =~ s/(.+)(\/NAME_STREET) (.+)/$1 $3$2/;
         @toks[$i+1] = "";
         @toks[$i+2]= "";
      }
      elsif(@toks[$i+2] =~ /\d/){
         @toks[$i] = "@toks[$i] @toks[$i+2]";
         @toks[$i] =~ s/(.+)(\/NAME_STREET) (\d+[A-Z]?)/$1 $3$2/;
         @toks[$i+1] = "";
         @toks[$i+2]= "";
      }
      elsif(@toks[$i-2] =~ /\d+/){		
         @toks[$i] = "@toks[$i-2] @toks[$i]";
         @toks[$i-1] = "";
         @toks[$i-2]= "";
      }
      elsif(@toks[$i-4] =~ /\d+/){		
         @toks[$i] = "@toks[$i-4] @toks[$i]";
         @toks[$i-1] = "";
         @toks[$i-2]= "";
         @toks[$i-3] = "";
         @toks[$i-4] = "";
      } 
   } 

   elsif( @toks[$i] =~/NAME_CITY/){		
     if(@toks[$i-2] =~ /^[A-Z]*\d+[A-Z]*$/){
       @toks[$i-2]=~ s/\/NAME_[A-Z\_\/]+//;
       @toks[$i] = "@toks[$i-2] @toks[$i]";
       @toks[$i-1] = "";
       @toks[$i-2]= "";
      }
   } 
   
    if(@toks[$i] =~ /^[A-ZÆØÅ]$\/NAME_MISC$/){
          @toks[$i] =~ s/\/NAME_MISC[\INIT]*//g;  
    }
 } 
} 

#------------------------------------------------------------------------ 
#	  OUTPUT
#------------------------------------------------------------------------ 
    foreach $tok(@toks){
      $tok =~ s/\/NAME_VEJ//;
      $tok =~ s/^(\p{Lu})\/NAME_.+$/$1/;  
      $tok =~ s/\=/ /g;
      
      $tok =~ s/\*s\*/ /g;
      $tok =~ s/\*t\*/\t/g;
      $tok =~ s/\*n\*/\n/g;
      $tok =~ s/\*r\*//g;
      $tok =~ s/(.+)(\/NAME[\_\/A-Z]+) (.+)(\/NAME[\_\/A-Z]+)/$1 $3$2$4/;

    #--------------------------------
        
    if($tok =~ /\/NAME_PERS_FIRST/){	
        $tok =~ s/PERS_FIRST/person/;
        $certain = "2";
      }
    elsif($tok =~ /\/NAME_PERS_LAST/){
        $certain = "2";
        $tok =~ s/NAME_PERS_LAST/NAME_person/;        
      }
     elsif($tok =~ /NAME_PERS_MAYBE/){	
        $tok =~ s/NAME_PERS_MAYBE/NAME_person/;
        $certain = "2";
      }     
     elsif($tok =~ /NAME_CITY/){
       if($tok =~ /^\d*\s*\p{Lu}\p{Ll}+[\s\p{Lu}\.\,]*\/NAME_CITY_DK+[\/NAME\_MISC]*[\,\.\:]*$/){
         $tok =~ s/\/NAME_MISC//g;
         $tok =~ s/NAME_CITY_DK/NAME_city/g;
         $certain = "1";
       }
       elsif($tok =~ /^\d+\p{Lu}*\s\p{Lu}\p{Ll}+\/NAME_CITY_UL[\/NAME\_MISC]*[\,\.\:]*$/){  
         $tok =~ s/\/NAME_MISC//g;
         $tok =~ s/NAME_CITY_UL/NAME_city/g;
         $certain = "1";
       }
       elsif($tok =~ /^\p{Lu}\p{Ll}+\/NAME_CITY_UL[\/NAME\_MISC]*[\,\.\:]*$/){ 
         $tok =~ s/\/NAME_MISC//g;
         $tok =~ s/NAME_CITY_UL/NAME_city/g;
         $certain = "1";
       }
       else{	
        $tok =~ s/NAME_CITY_DK[\/NAME\_MISCT]*/NAME_misc/g;
        $tok =~ s/NAME_CITY_UL[\/NAME\_MISCT]*/NAME_misc/g;
        $certain = "2";
      }  
     } 
     
      elsif($tok =~ /NAME_MISC_INIT/){
        $tok =~ s/NAME_MISC_INIT/NAME_misc/g;
        $certain = "3";
      }
      elsif($tok =~ /NAME_MISC/){
       $tok =~ s/NAME_MISC/NAME_misc/g;
       $certain = "3";
      }            
      elsif($tok =~ /NAME_PERS/){
        $tok =~ s/NAME_PERS/NAME_person/g;
        $certain = "1";
      } 
      elsif($tok =~ /NAME_COUNTRY/){
        $tok =~ s/NAME_COUNTRY/NAME_country/g;
        $certain = "1";
      } 
	  elsif($tok =~ /NAME_COMP$/){
        $tok =~ s/NAME_COMP/NAME_organisation/g;  
        $certain = "1";
      }
      elsif($tok =~ /\/NAME_STREET/){
        $certain = "1";
        $tok =~ s/NAME_STREET/NAME_street/;        
      }
      elsif($tok =~ /\/NAME_PLACE/){
        $certain = "1";
        $tok =~ s/NAME_PLACE/NAME_place/;        
      }
 
      elsif($tok =~ /\/NAME_ISLAND/){
        $tok =~ s/NAME_ISLAND/NAME_place/;
        $certain = "1";
      } 
	  elsif($tok =~ /NAME_ORG/){
        $tok =~ s/NAME_ORG/NAME_organisation/g;  
        $certain = "1";
      }
      elsif($tok =~ /\/NAME_SING/){
        $tok =~ s/\/NAME_SING//
      }       

     $cat = $tok;
     $name = $tok;
     


     if($name =~/\/NAME_COMP/){
       $cat = "organisation";
       $certain = "1";
       $name =~ s/\/NAME_COMP//;
     }
     
     
       $name =~ s/\/NAME_.+//;
 #-------------------------------------------------    
     $cat =~ s/(.+)\/N[AMEUM]+\_([a-z\-]+)(.)*/$2/;
     $cat =~ s/\/NAME.+//;
     $name =~ s/(.+)\/NAME\_([a-z\-]+)(.)*/$1/;
     $num =~ s/(.+)\/NUM\_([a-z\-]+)(.)*/$1/;
     $name =~ s/\/NAME_[a-z\-]+ / /;
     $name =~ s/\/NAME.+//;
     $name =~ s/_INIT//;     
     if($certain eq ""){
       $certain = "4";
     }     
#     $tok =~ s/(.+\/NAME[A-Za-z\-\_]+)([\,\.\?\)\]\:\;\!\"\']*)/<NE cat=\"$cat\"\ certain=\"$certain\">$name<\/NE>$2/g;
     if($certain eq 1)      {$certain = "certain";}
     else {if($certain eq 2) {$certain = "likely";}
     else                   {$certain = "uncertain";}}
     $tok =~ s/(.+\/NAME[A-Za-z\-\_]+)([\,\.\?\)\]\:\;\!\"\']*)/\[$name,$cat,$certain\]$2/g;
       
#------------------------------------------------------------------------ 
#	    Print options
#------------------------------------------------------------------------       
     print "$tok";                                    # Print all
     #if($tok =~ /<NE cat=\"/){print "$tok\n"}         # Print only NE tags
     #print "\n";                                      # One token a line
#------------------------------------------------------------------------ 

     $certain = "";
  } 
} 

