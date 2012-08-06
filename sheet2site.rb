require 'csv'
#========================================================================================
# User Settings

@siteName = "Edin Shows" # Enter the site name here
@indexIntroText = "Sorted as per originating spreadsheet" # Enter text to appear on Index pageData
@contentPageIntroText = "Show info" # Enter text that appears on the individual content page






#========================================================================================
#Set up the data we will be working with
csvContent = CSV.parse(File.read(ARGV[0]))

@headings = csvContent [0] # Get the headings to use later as the keys for the Hashes

# get the content (without the headers)
@content = Array.new
@content.replace(csvContent)
@content.delete_at(0) # remove the headers from the content array

# create an array to hold the hashes we generate
@structuredDataArray = Array.new


#========================================================================================
# Build the data structures

# Generates an array of hashes containing the headings as the hash keys and a line cell of content against each of the keys
def getArrayOfContentHashes
	
	# loop through the content array and generate hashes from each line of content
	@content.each do |currentObject|
		
		# create a hash
		pageHash = Hash[@headings.zip currentObject]
		
		#push the hash on to the structured contentArray
		@structuredDataArray << pageHash

	end

end

#========================================================================================
# Generate html pages from the Data

def indexHeader # Header text
	header = "<html><head><title>Index</title><link rel=\"stylesheet\" type=\"text/css\" href=\"contentpages/main.css\" /></head><body><font face=helvetica>"
end

def header (pageTitle) # Header text
	header = "<html><head><title>" + pageTitle + "</title><link rel=\"stylesheet\" type=\"text/css\" href=\"main.css\" /></head><body><font face=helvetica>"
end

def footer # Footer text
	footer = "</body></html>"
end

def scanForLinks (candidateString) # V crude. Needs to be improved
	
	# Brake down the candidateString into an array of strings separated by a space
	stringArray = candidateString.split(' ')
	
	# Scan the individual array entries for occurrences of http
	newStringArray = Array.new
	stringArray.each do |subString|
		
		match = 0
		
		subString.scan('http') do |w| 
			newStringArray << "<a href=\"#{subString}\">#{subString}</a>"
			match = 1
		end
		
		# add in extra conditions here
		
		if match == 0
			newStringArray << subString
		end
		
		
		
	end
	
	#rebuild the string
	returnString = 	newStringArray.join(" ")
	
end

def generateHTMLPage (pageDataHash)
		
	# pull out the page title from the array. We can assume it's the first value
	values = pageDataHash.values
	title = values [0]
	
	#Get the header and footer text
	headerText = header(title)
	footerText = footer
	
	#Generate the body text
	bodyText = String.new
	
	bodyText << "<h1><a href=\"../index.html\">" + @siteName + "</a> / " + title + "</h1>"
	bodyText << @contentPageIntroText + "<hr>"
	
	pageDataHash.each do |key, value| # Build the page content
		
		if key == nil
			key = " "
		end
		
		if value == nil
			value = "Nothing Entered"
		end
		
		#puts key + value
		element = "<p><h3> " + key + " </h3> " + value + " <p>"
		
		bodyText << element # Append the body string with the new info
		
		
		
	end
	
	bodyText = scanForLinks(bodyText) #scan the resultant string for links
	
	finalText = String.new
	finalText = headerText + bodyText + footer
	
	# clear the strings in prep for the next
	element = nil
	bodyText = nil
	
	
	# save the file out to the folder structure
	# save the file
	
	filename = "site/contentpages/" + title.scan(/\w+/).join('_') + ".html"
	aFile = File.new(filename, "w")
	aFile.write(finalText)
	aFile.close
	
	

	

end

#========================================================================================
# Create an index File

def createIndexFile
	
	indexContent = String.new # Holds the content in HTML format
	
	indexContent << indexHeader
	indexContent << "<h1>" + @siteName + "</h1>" # Insert title
	indexContent << @indexIntroText + "<hr>"
	
	# Loop through the content and get the first and second items in the Array
	@content.each do |object|
	
		# Get the title. We want to make this a link
		item1 = object [0]
		item2 = object [1]
		
		# Make a link out of item 1
		link = "contentpages/" + item1.scan(/\w+/).join('_') + ".html"
		
		# build the item information
		entryString = "<h3><a href=\"" + link + "\">" + item1 +	"</a></h3><p>" + item2 + "<\p>"
	
		indexContent << entryString
		
	end
	
	indexContent << footer
	
	filename = "site/index.html"
	iFile = File.new(filename, "w")
	iFile.write(indexContent)
	iFile.close



end

#========================================================================================
# Create a simple CSS file for the site

def generateCSS

	css = "body{padding-top:25px; padding-bottom:25px; padding-right:50px; padding-left:50px;}p{line-height:140%; font-size:14px;}code{border-style:dotted; border-width:1px;}ul{line-height: 140%; font-size:14px;}H1{font-size:22px;}H2{font-size:20px;}H3{font-size:18px;}H4{font-size:16px;}"
	
	
	
	# Write the File
	filename = "site/contentpages/main.css"
	iFile = File.new(filename, "w")
	iFile.write(css)
	iFile.close

end

#========================================================================================
# Create a file structure for the site

def createFileStructure
	
	Dir.mkdir("site")
	Dir.mkdir("site/contentpages")

end

#========================================================================================

# Generate the file structure for the site
createFileStructure

# Generate a structured set of data to make the pages from
getArrayOfContentHashes

# Generate the pages from the data
@structuredDataArray.each {|pageData| generateHTMLPage(pageData)}

# Generate index pages
createIndexFile

# Generate a basic CSS file
generateCSS
