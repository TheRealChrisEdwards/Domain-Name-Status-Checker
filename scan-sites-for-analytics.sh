#!/bin/bash

list_of_domains=$(egrep -iv 'ftp' output.txt | awk -F ',' '{ print $1 }')
webtrends_evidence="webtrendslive.com"
google_evidence="google-analytics"
output_dir="output_cache"
output_file="scan-for-analytics.out.txt"

if [ ! -d  $output_dir ]; then
	mkdir $output_dir
fi

if [[ $# -eq 1 && $1 == '--refresh' ]]; then

	rm $output_dir/*html

	for domain in ${list_of_domains[*]}
	do
		domain_file=$output_dir/$domain.html
		curl --include --connect-timeout 5 --silent -L --max-redirs 3 $domain -o $domain_file
	done
fi

echo 'url,redirects to,destination has google?,destination has webtrends?' > $output_file

for domain in ${list_of_domains[*]}
do
	domain_file=$output_dir/$domain.html
	has_google='FALSE'
	has_webtrends='FALSE'

	echo "Processing $domain"

	if [ -e  $domain_file ]; then

		if [ $(egrep -i "$google_evidence" $domain_file | wc -l) -gt 0 ]; then
			echo "Google line: $(egrep -i "$google_evidence" $domain_file | wc -l)"
			has_google='TRUE'
		fi
		if [ $(egrep -i "$webtrends_evidence" $domain_file | wc -l) -gt 0 ]; then
			echo "Webtrends line: $(egrep -i "$webtrends_evidence" $domain_file | wc -l)"
			has_webtrends='TRUE'
		fi

		location=$(egrep '^Location' $domain_file | sed 's/^.*\/\///' | tail -1 | xargs)

		echo "$domain,$location,$has_google,$has_webtrends" >> $output_file
	fi

	
done

