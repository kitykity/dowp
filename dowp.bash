#!/bin/bash
# dowp.bash
# Export WordPress posts--"posts," not everything.
# Import WordPress posts into Day One.
# by Susan Pitman
# 11/12/14 Script created.
# 11/15/14 Fixed title so it would show up bold (\r\n)
thisDir=`pwd`

set -x

makePostFiles () {
  if [ -d "${thisDir}/dowpPosts" ]; then
    echo "The posts directory already exists."
   else
    mkdir ${thisDir}/dowpPosts
  fi

  fileNum="0"
  echo "" > "${thisDir}/dowpPosts/post.0.xml"
  while read thisLine ; do
    if echo ${thisLine} | grep "<item>" > /dev/null ; then
      printf "."
      ((fileNum++))
      fileNumPadded=`printf %06d $fileNum`
      echo ${thisLine} > ${thisDir}/dowpPosts/post.${fileNumPadded}.xml
     else
      echo ${thisLine} >> ${thisDir}/dowpPosts/post.${fileNumPadded}.xml
    fi
  done < ${thisDir}/wordpress.xml
  rm "${thisDir}/dowpPosts/post..xml" "${thisDir}/dowpPosts/post.0.xml" 2> /dev/null #Garbage file
}

postPopper () {
  for fileName in `ls ${thisDir}/dowpPosts/p*` ; do
    postDateTime=`grep "<wp:post_date>" ${fileName} | sed -e 's/<wp:post_date>//' | sed -e 's/<\/wp:post_date>//' | sed -e 's/<\!\[CDATA\[//' | sed 's/\]\]>//'`
    postTitle=`grep "<title>" ${fileName} | sed -e 's/<title>//' | sed -e 's/<\/title>//'`
    postText2=`cat ${fileName} | sed -n '/<content:encoded>/,/<\/content:encoded>/p' | sed -e 's/<content:encoded><\!\[CDATA\[//' | sed '/<excerpt:encoded>/,$d' | sed 's/\]\]><\/content:encoded>//'`
    postText=`printf "${postTitle}\r\n\n${postText2}"`
    printf "\nFilename: ${fileName}\n"
    printf "Post Date: ${postDateTime}\n"
    shortPost=`echo ${postText2} | cut -c1-100`
    printf "Title: ${postTitle}\n"
    printf "${shortPost}\n"
    echo ${postText} | /usr/local/bin/dayone2 -d="${postDateTime}" new
    shortName=`echo ${fileName} | tr '/' '\n' | tail -1`
    mv ${fileName} ${thisDir}/dowpPosts/done.${shortName}
    printf "`ls ${thisDir}/dowpPosts/p* | wc -l` posts left to import.\n\n"
    sleep 5
    printf "Hit Enter for the next one... " ; read m
  done
}

## MAIN ##
makePostFiles   # Create one file for each post.
postPopper      # Put posts into DayOne.
## END OF SCRIPT ##
