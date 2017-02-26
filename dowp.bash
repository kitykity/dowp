#!/bin/bash
# dowp.bash
# Export WordPress posts--"posts," not everything.
# Import WordPress posts into Day One.
# by Susan Pitman
# 11/12/14 Script created.
# 11/15/14 Fixed title so it would show up bold (\r\n)
thisDir=`pwd`

makePostFiles () {
  if ls -ld ${thisDir}/dowpPosts ; then
    printf "The posts directory already exists.\n"
   else
    mkdir ${thisDir}/dowpPosts
  fi
  fileNum="0"
  echo "" > "${thisDir}/dowpPosts/post.0"
  while read thisLine ; do
    if echo ${thisLine} | grep "<item>" > /dev/null ; then
      printf "."
      ((fileNum++))
      fileNumPadded=`printf %06d $fileNum`
      echo ${thisLine} > ${thisDir}/dowpPosts/post.${fileNumPadded}
     else
      echo ${thisLine} >> ${thisDir}/dowpPosts/post.${fileNumPadded}
    fi
  done < ${thisDir}/wordpress.xml
}

postPopper () {
  rm "${thisDir}/dowpPosts/post." "${thisDir}/dowpPosts/post.0" 2> /dev/null #Garbage file
  for fileName in `ls ${thisDir}/dowpPosts/p*` ; do
    postDateTime=`grep "<wp:post_date>" ${fileName} | sed -e 's/<wp:post_date>//' | sed -e 's/<\/wp:post_date>//' | sed -e 's/\-/\//g'`
    postYear=`echo ${postDateTime} | cut -d"/" -f1 | egrep -o '[[:digit:]]{4}' | head -n1`
    postMonth=`echo ${postDateTime} | cut -d"/" -f2`
    postDay=`echo ${postDateTime} | cut -d"/" -f3 | cut -d" " -f1`
    postHour=`echo ${postDateTime} | cut -d" " -f2 | cut -d":" -f1`
    if [ ${postHour} -gt "12" ] ; then
      postHour=`expr ${postHour} - 12`
      postAMPM="PM"
     else
      postAMPM="AM"
    fi
    postMinute=`echo ${postDateTime} | cut -d" " -f2 | cut -d":" -f2`
    postTitle=`grep "<title>" ${fileName} | sed -e 's/<title>//' | sed -e 's/<\/title>//'`
    #postText2=`cat ${fileName} | sed -n '/<content:encoded>/,/<\/content:encoded>/p' | sed -e 's/<content:encoded><\!\[CDATA\[//' | sed -e 's/\]\]><\/content:encoded>//'`
    postText2=`cat ${fileName} | sed -n '/<content:encoded>/,/<\/content:encoded>/p' | sed -e 's/<content:encoded><\!\[CDATA\[//' | sed '/<excerpt:encoded>/,$d' | sed 's/\]\]><\/content:encoded>//'`
    postText=`printf "${postTitle}\r\n\n${postText2}"`
    postDateTimeForDayOne="${postMonth}/${postDay}/${postYear} ${postHour}:${postMinute}${postAMPM}"
    printf "\nFilename: ${fileName}\n"
    printf "Post Date: ${postDateTimeForDayOne}\n"
    shortPost=`echo ${postText2} | cut -c1-100`
    printf "Title: ${postTitle}\n"
    printf "${shortPost}\n"
    echo ${postText} | /usr/local/bin/dayone2 -d="${postDateTimeForDayOne}" new
    shortName=`echo ${fileName} | tr '/' '\n' | tail -1`
    mv ${fileName} ${thisDir}/dowpPosts/done.${shortName}
    printf "`ls ${thisDir}/dowpPosts/p* | wc -l` posts left to import.\n\n"
    sleep 5
    #printf "Hit Enter for the next one... " ; read m
  done
}

## MAIN ##
makePostFiles   # Create one file for each post.
postPopper      # Put posts into DayOne.
## END OF SCRIPT ##
