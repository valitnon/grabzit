# The public REST API for http://grabz.it
# @example To include the GrabzIt module do the following
#    require 'grabzit'
module GrabzIt
	require 'digest/md5'
	require 'net/http'
	require 'rexml/document'
	require 'cgi'
	require 'uri'
	require File.join(File.dirname(__FILE__), 'screenshotstatus')
	require File.join(File.dirname(__FILE__), 'cookie')
	require File.join(File.dirname(__FILE__), 'watermark')
	require File.join(File.dirname(__FILE__), 'exception')

	# This client provides access to the GrabzIt web services
	# This API allows you to take screenshot of websites for free and convert them into images, PDF's and tables.
	# @example Example usage
	#    require 'grabzit'	
	#
	#    grabzItClient = GrabzIt::Client.new("YOUR APPLICATION KEY", "YOUR APPLICATION SECRET")
	#    grabzItClient.set_image_options("http://www.google.com")
	#    grabzItClient.save("http://www.mysite.com/grabzit/handler")
	# @version 2.1
	# @author GrabzIt
	# @see http://grabz.it/api/ruby/ GrabzIt Ruby API
	class Client

		WebServicesBaseURL = "http://api.grabz.it/services/"
		private_constant :WebServicesBaseURL	
		TrueString = "True"
		private_constant :TrueString

		@@signaturePartOne;
		@@signaturePartTwo;
		@@startDelay;		
		@@request;
		
		# Create a new instance of the Client class in order to access the GrabzIt API.
		#
		# @param applicationKey [String] your application key
		# @param applicationSecret [String] your application secret
		# @see http://grabz.it/register.aspx You can get an application key and secret by registering for free with GrabzIt		
		def initialize(applicationKey, applicationSecret)
			@applicationKey = applicationKey
			@applicationSecret = applicationSecret
		end

		# This method sets the parameters required to turn a online video into a animated GIF
		#
		# @param url [String] the URL of the online video
		# @param customId [String, nil] custom identifier that you can pass through to the animated GIF web service. This will be returned with the callback URL you have specified
		# @param width [Integer, 0] the width of the resulting animated GIF in pixels
		# @param height [Integer, 0] the height of the resulting animated GIF in pixels
		# @param start [Integer, 0] the starting position of the video that should be converted into a animated GIF
		# @param duration [Integer, 0] the length in seconds of the video that should be converted into a animated GIF
		# @param speed [Float, 0] the speed of the animated GIF from 0.2 to 10 times the original speed
		# @param framesPerSecond [Float, 0] the number of frames per second that should be captured from the video. From a minimum of 0.2 to a maximum of 60
		# @param repeat [Integer, 0] the number of times to loop the animated GIF. If 0 it will loop forever
		# @param reverse [Boolean, false] if true the frames of the animated GIF are reversed
		# @param customWaterMarkId [String, nil] add a custom watermark to the animated GIF
		# @param quality [Integer, -1] the quality of the image where 0 is poor and 100 excellent. The default is -1 which uses the recommended quality
		# @param country [String, nil] request the screenshot from different countries: Default, UK or US
		# @return [void]		
		def set_animation_options(url, customId = nil, width = 0, height = 0, start = 0, duration = 0, speed = 0, framesPerSecond = 0, repeat = 0, reverse = false, customWaterMarkId = nil, quality = -1, country = nil)
			@@startDelay = 0;
			@@request = WebServicesBaseURL + "takeanimation.ashx?key=" + CGI.escape(nil_check(@applicationKey))+"&url="+CGI.escape(nil_check(url))+"&width="+nil_int_check(width)+"&height="+nil_int_check(height)+"&duration="+nil_int_check(duration)+"&speed="+nil_float_check(speed)+"&start="+nil_int_check(start)+"&customid="+CGI.escape(nil_check(customId))+"&fps="+nil_float_check(framesPerSecond)+"&repeat="+nil_int_check(repeat)+"&customwatermarkid="+CGI.escape(nil_check(customWaterMarkId))+"&reverse="+b_to_str(reverse)+"&country="+CGI.escape(nil_check(country))+"&quality="+nil_int_check(quality)+"&callback="			
			@@signaturePartOne = @applicationSecret+"|"+nil_check(url)+"|"
			@@signaturePartTwo = "|"+nil_int_check(height)+"|"+nil_int_check(width)+"|"+nil_check(customId)+"|"+nil_float_check(framesPerSecond)+"|"+nil_float_check(speed)+"|"+nil_int_check(duration)+"|"+nil_int_check(repeat)+"|"+b_to_str(reverse)+"|"+nil_int_check(start)+"|"+nil_check(customWaterMarkId)+"|"+nil_check(country)+"|"+nil_int_check(quality)
			return nil
		end


		# Sets the parameters required to take a screenshot of a web page.
		#
		# @param url [String] the URL that the screenshot should be made of
		# @param customId [String, nil] custom identifier that you can pass through to the screenshot web service. This will be returned with the callback URL you have specified.	
		# @param browserWidth [Integer, nil] the width of the browser in pixels
		# @param browserHeight [Integer, nil] the height of the browser in pixels
		# @param width [Integer, nil] the width of the resulting thumbnail in pixels
		# @param height [Integer, nil] the height of the resulting thumbnail in pixels		
		# @param format [String, nil] the format the screenshot should be in: bmp8, bmp16, bmp24, bmp, gif, jpg, png
		# @param delay [Integer, nil] the number of milliseconds to wait before taking the screenshot
		# @param targetElement [String, nil] the id of the only HTML element in the web page to turn into a screenshot
		# @param requestAs [Integer, 0] request the screenshot in different forms: Standard Browser = 0, Mobile Browser = 1, Search Engine = 2 and Fallback Browser = 3
		# @param customWaterMarkId [String, nil] add a custom watermark to the image
		# @param quality [Integer, -1] the quality of the image where 0 is poor and 100 excellent
		# @param country [String, nil] request the screenshot from different countries: Default = "", UK = "UK", US = "US"
		# @return [void]		
		def set_image_options(url, customId = nil, browserWidth = nil, browserHeight = nil, width = nil, height = nil, format = nil, delay = nil, targetElement = nil, requestAs = 0, customWaterMarkId = nil, quality = -1, country = nil)

			if delay == nil
				@@startDelay = 0
			else
				@@startDelay = delay
			end
			
			@@request = WebServicesBaseURL + "takepicture.ashx?key="+CGI.escape(nil_check(@applicationKey))+"&url="+CGI.escape(nil_check(url))+"&width="+nil_int_check(width)+"&height="+nil_int_check(height)+"&format="+CGI.escape(nil_check(format))+"&bwidth="+nil_int_check(browserWidth)+"&bheight="+nil_int_check(browserHeight)+"&customid="+CGI.escape(nil_check(customId))+"&delay="+nil_int_check(delay)+"&target="+CGI.escape(nil_check(targetElement))+"&customwatermarkid="+CGI.escape(nil_check(customWaterMarkId))+"&requestmobileversion="+nil_int_check(requestAs)+"&country="+CGI.escape(nil_check(country))+"&quality="+nil_int_check(quality)+"&callback="
			@@signaturePartOne = nil_check(@applicationSecret)+"|"+nil_check(url)+"|"
			@@signaturePartTwo = "|"+nil_check(format)+"|"+nil_int_check(height)+"|"+nil_int_check(width)+"|"+nil_int_check(browserHeight)+"|"+nil_int_check(browserWidth)+"|"+nil_check(customId)+"|"+nil_int_check(delay)+"|"+nil_check(targetElement)+"|"+nil_check(customWaterMarkId)+"|"+nil_int_check(requestAs)+"|"+nil_check(country)+"|"+nil_int_check(quality)

			return nil
		end

		# Sets the parameters required to extract one or more tables from a web page.
		#
		# @param url [String] the URL that the should be used to extract tables
		# @param customId [String, nil] a custom identifier that you can pass through to the web service. This will be returned with the callback URL you have specified.	
		# @param tableNumberToInclude [Integer, 1] the index of the table to be converted, were all tables in a web page are ordered from the top of the web page to bottom
		# @param format [String, 'csv'] the format the table should be in: csv, xlsx
		# @param includeHeaderNames [Boolean, true] if true header names will be included in the table
		# @param includeAllTables [Boolean, true] if true all table on the web page will be extracted with each table appearing in a separate spreadsheet sheet. Only available with the XLSX format.
		# @param targetElement [String, nil] the id of the only HTML element in the web page that should be used to extract tables from
		# @param requestAs [Integer, 0] request the screenshot in different forms: Standard Browser = 0, Mobile Browser = 1, Search Engine = 2 and Fallback Browser = 3
		# @param country [String, nil] request the screenshot from different countries: Default = "", UK = "UK", US = "US"		
		# @return [void]
		def set_table_options(url, customId = nil, tableNumberToInclude = 1, format = 'csv', includeHeaderNames = true, includeAllTables = false, targetElement = nil, requestAs = 0, country = nil)
			@@startDelay = 0
			
			@@request = WebServicesBaseURL + "taketable.ashx?key=" + CGI.escape(nil_check(@applicationKey))+"&url="+CGI.escape(url)+"&includeAllTables="+b_to_str(includeAllTables)+"&includeHeaderNames="+b_to_str(includeHeaderNames)+"&format="+CGI.escape(nil_check(format))+"&tableToInclude="+nil_int_check(tableNumberToInclude)+"&customid="+CGI.escape(nil_check(customId))+"&target="+CGI.escape(nil_check(targetElement))+"&requestmobileversion="+nil_int_check(requestAs)+"&country="+CGI.escape(nil_check(country))+"&callback="
			@@signaturePartOne = nil_check(@applicationSecret)+"|"+nil_check(url)+"|"
			@@signaturePartTwo = "|"+nil_check(customId)+"|"+nil_int_check(tableNumberToInclude)+"|"+b_to_str(includeAllTables)+"|"+b_to_str(includeHeaderNames)+"|"+nil_check(targetElement)+"|"+nil_check(format)+"|"+nil_int_check(requestAs)+"|"+nil_check(country)

			return nil
		end	

		# Sets the parameters required to convert a web page into a PDF.
		#
		# @param url url [String] the URL that the should be converted into a pdf
		# @param customId [String, nil] a custom identifier that you can pass through to the web service. This will be returned with the callback URL you have specified.
		# @param includeBackground [Boolean, true] if true the background of the web page should be included in the screenshot
		# @param pagesize [String, 'A4'] the page size of the PDF to be returned: 'A3', 'A4', 'A5', 'B3', 'B4', 'B5', 'Letter'.
		# @param orientation [String, 'Portrait'] the orientation of the PDF to be returned: 'Landscape' or 'Portrait'
		# @param includeLinks [Boolean, true] true if links should be included in the PDF
		# @param includeOutline [Boolean, false] True if the PDF outline should be included
		# @param title [String, nil] provide a title to the PDF document
		# @param coverURL [String, nil] the URL of a web page that should be used as a cover page for the PDF
		# @param marginTop [Integer, 10] the margin that should appear at the top of the PDF document page
		# @param marginLeft [Integer, 10] the margin that should appear at the left of the PDF document page
		# @param marginBottom [Integer, 10] the margin that should appear at the bottom of the PDF document page
		# @param marginRight [Integer, 10] the margin that should appear at the right of the PDF document
		# @param delay [Integer, nil] the number of milliseconds to wait before taking the screenshot
		# @param requestAs [Integer, 0] request the screenshot in different forms: Standard Browser = 0, Mobile Browser = 1, Search Engine = 2 and Fallback Browser = 3
		# @param customWaterMarkId [String, nil] add a custom watermark to each page of the PDF document
		# @param quality [Integer, -1] the quality of the PDF where 0 is poor and 100 excellent
		# @param country [String, nil] request the screenshot from different countries: Default = "", UK = "UK", US = "US"				
		# @return [void]
		def set_pdf_options(url, customId = nil, includeBackground = true, pagesize = 'A4', orientation = 'Portrait', includeLinks = true, includeOutline = false, title = nil, coverURL = nil, marginTop = 10, marginLeft = 10, marginBottom = 10, marginRight = 10, delay = nil, requestAs = 0, customWaterMarkId = nil, quality = -1, country = nil)
			pagesize = nil_check(pagesize).upcase
			$orientation = nil_check(orientation).capitalize
			
			if delay == nil
				@@startDelay = 0
			else
				@@startDelay = delay
			end	

			@@request = WebServicesBaseURL + "takepdf.ashx?key=" + CGI.escape(nil_check(@applicationKey))+"&url="+CGI.escape(nil_check(url))+"&background="+b_to_str(includeBackground)+"&pagesize="+pagesize+"&orientation="+orientation+"&customid="+CGI.escape(nil_check(customId))+"&customwatermarkid="+CGI.escape(nil_check(customWaterMarkId))+"&includelinks="+b_to_str(includeLinks)+"&includeoutline="+b_to_str(includeOutline)+"&title="+CGI.escape(nil_check(title))+"&coverurl="+CGI.escape(nil_check(coverURL))+"&mleft="+nil_int_check(marginLeft)+"&mright="+nil_int_check(marginRight)+"&mtop="+nil_int_check(marginTop)+"&mbottom="+nil_int_check(marginBottom)+"&delay="+nil_int_check(delay)+"&requestmobileversion="+nil_int_check(requestAs)+"&country="+CGI.escape(nil_check(country))+"&quality="+nil_int_check(quality)+"&callback="

			@@signaturePartOne = nil_check(@applicationSecret)+"|"+nil_check(url)+"|"
			@@signaturePartTwo = "|"+nil_check(customId)+"|"+b_to_str(includeBackground)+"|"+pagesize +"|"+orientation+"|"+nil_check(customWaterMarkId)+"|"+b_to_str(includeLinks)+"|"+b_to_str(includeOutline)+"|"+nil_check(title)+"|"+nil_check(coverURL)+"|"+nil_int_check(marginTop)+"|"+nil_int_check(marginLeft)+"|"+nil_int_check(marginBottom)+"|"+nil_int_check(marginRight)+"|"+nil_int_check(delay)+"|"+nil_int_check(requestAs)+"|"+nil_check(country)+"|"+nil_int_check(quality)

			return nil		
		end
		
		# Calls the GrabzIt web service to take the screenshot
		#
		# The handler will be passed a URL with the following query string parameters:
		# - message (is any error message associated with the screenshot)
		# - customId (is a custom id you may have specified in the {#set_image_options}, {#set_table_options} or {#set_pdf_options} method)
		# - id (is the unique id of the screenshot which can be used to retrieve the screenshot with the {#get_result} method)
		# - filename (is the filename of the screenshot)
		# - format (is the format of the screenshot)
		# @note This is the recommended method of saving a screenshot
		# @param callBackURL [String, nil] the handler the GrabzIt web service should call after it has completed its work
		# @return [String] the unique identifier of the screenshot. This can be used to get the screenshot with the {#get_result} method
		# @raise [RuntimeError] if the GrabzIt service reports an error with the request it will be raised as a RuntimeError
		def save(callBackURL = nil)
			if @@signaturePartOne == nil && @@signaturePartTwo == nil && @@request == nil
				  raise GrabzItException.new("No screenshot parameters have been set.", GrabzItException::PARAMETER_MISSING_PARAMETERS)
			end

			sig = encode(@@signaturePartOne+nil_check(callBackURL)+@@signaturePartTwo)
			currentRequest = @@request
			
			currentRequest += CGI.escape(nil_check(callBackURL))+"&sig="+sig

			return get_result_value(get(currentRequest), "ID")
		end   

		# Calls the GrabzIt web service to take the screenshot and saves it to the target path provided. if no target path is provided
		# it returns the screenshot byte data.
		#
		# @note Warning, this is a SYNCHONOUS method and can take up to 5 minutes before a response
		# @param saveToFile [String, nil] the file path that the screenshot should saved to. 
		# @example Synchronously save the screenshot to test.jpg
		#   save_to('images/test.jpg')
		# @raise [RuntimeError] if the screenshot cannot be saved a RuntimeError will be raised that will contain an explanation
		# @return [Boolean] returns the true if it is successfully saved to a file, otherwise if a target path is not provided it returns the screenshot's byte data.
		def save_to(saveToFile = nil)
			id = save()

			if id == nil || id == ""
				return false
			end			
			
			#Wait for it to be possibly ready
			sleep((@@startDelay / 1000) + 3)

			#Wait for it to be ready.
			while true do
				status = get_status(id)

				if !status.cached && !status.processing
					raise GrabzItException.new("The screenshot did not complete with the error: " + status.Message, GrabzItException::RENDERING_ERROR)
					break
				elsif status.cached
					result = get_result(id)
					if !result
						raise GrabzItException.new("The screenshot could not be found on GrabzIt.", GrabzItException::RENDERING_MISSING_SCREENSHOT)
						break
					end
					
					if saveToFile == nil || saveToFile == ""
						return result
					end					

					screenshot = File.new(saveToFile, "wb")
					screenshot.write(result)
					screenshot.close				

					break
				end

				sleep(3)
			end

			return true
		end	

		# Get the current status of a GrabzIt screenshot
		#
		# @param id [String] the id of the screenshot
		# @return [ScreenShotStatus] a object representing the status of the screenshot
		def get_status(id)
			
			if id == nil || id == ""
				return nil
			end			
			
			result = get(WebServicesBaseURL + "getstatus.ashx?id=" + nil_check(id))

			doc = REXML::Document.new(result)

			processing = doc.root.elements["Processing"].text()
			cached = doc.root.elements["Cached"].text()
			expired = doc.root.elements["Expired"].text()
			message = doc.root.elements["Message"].text()

			return ScreenShotStatus.new((processing == TrueString), (cached == TrueString), (expired == TrueString), message)
		end	

		# This method returns the screenshot itself. If nothing is returned then something has gone wrong or the screenshot is not ready yet
		#
		# @param id [String] the id of the screenshot
		# @return [Object] returns the screenshot
		# @raise [RuntimeError] if the GrabzIt service reports an error with the request it will be raised as a RuntimeError
		def get_result(id)
			if id == nil || id == ""
				return nil
			end
			
			return get(WebServicesBaseURL + "getfile.ashx?id=" + nil_check(id))
		end

		# Get all the cookies that GrabzIt is using for a particular domain. This may include your user set cookies as well
		#
		# @param domain [String] the domain to return cookies for
		# @return [Array<Cookie>] an array of cookies
		# @raise [RuntimeError] if the GrabzIt service reports an error with the request it will be raised as a RuntimeError
		def get_cookies(domain)
			sig = encode(nil_check(@applicationSecret)+"|"+nil_check(domain))               

			qs = "key=" +CGI.escape(nil_check(@applicationKey))+"&domain="+CGI.escape(nil_check(domain))+"&sig="+sig

			result = get(WebServicesBaseURL + "getcookies.ashx?" + qs)

			doc = REXML::Document.new(result)

			check_for_exception(doc)

			cookies = Array.new

			xml_cookies = doc.elements.to_a("//WebResult/Cookies/Cookie")		
			xml_cookies.each do |cookie|
				expires = nil
				if cookie.elements["Expires"] != nil                        
					expires = cookie.elements["Expires"].text
				end                
				grabzItCookie = GrabzIt::Cookie.new(cookie.elements["Name"].text, cookie.elements["Domain"].text, cookie.elements["Value"].text, cookie.elements["Path"].text, (cookie.elements["HttpOnly"].text == TrueString), expires, cookie.elements["Type"].text)
				cookies << grabzItCookie
			end

			return cookies
		end

		# Sets a new custom cookie on GrabzIt, if the custom cookie has the same name and domain as a global cookie the global
		#
		# cookie is overridden
		# @note This can be useful if a websites functionality is controlled by cookies
		# @param name [String] the name of the cookie to set
		# @param domain [String] the domain of the website to set the cookie for
		# @param value [String, ''] the value of the cookie
		# @param path [String, '/'] the website path the cookie relates to
		# @param httponly [Boolean, false] is the cookie only used on HTTP
		# @param expires [String, ''] when the cookie expires. Pass a nil value if it does not expire	
		# @return [Boolean] returns true if the cookie was successfully set
		# @raise [RuntimeError] if the GrabzIt service reports an error with the request it will be raised as a RuntimeError
		def set_cookie(name, domain, value = "", path = "/", httponly = false, expires = "")
			sig = encode(nil_check(@applicationSecret)+"|"+nil_check(name)+"|"+nil_check(domain)+"|"+nil_check(value)+"|"+nil_check(path)+"|"+b_to_str(httponly)+"|"+nil_check(expires)+"|0")

			qs = "key=" +CGI.escape(nil_check(@applicationKey))+"&domain="+CGI.escape(nil_check(domain))+"&name="+CGI.escape(nil_check(name))+"&value="+CGI.escape(nil_check(value))+"&path="+CGI.escape(nil_check(path))+"&httponly="+b_to_str(httponly)+"&expires="+CGI.escape(nil_check(expires))+"&sig="+sig

			return (get_result_value(get(WebServicesBaseURL + "setcookie.ashx?" + qs), "Result") == TrueString)
		end

		# Delete a custom cookie or block a global cookie from being used
		#
		# @param name [String] the name of the cookie to delete
		# @param domain [String] the website the cookie belongs to
		# @return [Boolean] returns true if the cookie was successfully set
		# @raise [RuntimeError] if the GrabzIt service reports an error with the request it will be raised as a RuntimeError
		def delete_cookie(name, domain)
			sig = encode(nil_check(@applicationSecret)+"|"+nil_check(name)+"|"+nil_check(domain)+"|1")

			qs = "key=" + CGI.escape(nil_check(@applicationKey))+"&domain="+CGI.escape(nil_check(domain))+"&name="+CGI.escape(nil_check(name))+"&delete=1&sig="+sig

			return (get_result_value(get(WebServicesBaseURL + "setcookie.ashx?" + qs), "Result") == TrueString)
		end

		# Get your uploaded custom watermark
		#
		# @param identifier [String, nil] the identifier of a particular custom watermark you want to view
		# @return [WaterMark] the watermark with the specified identifier
		def get_watermark(identifier)
			watermarks = get_watermarks(identifier)
			if watermarks.length == 1
				return watermarks[0];
			end
			
			return nil
		end

		# Get your uploaded custom watermarks
		#
		# @return [Array<WaterMark>] an array of uploaded watermarks
		def get_watermarks()
			return get_watermarks(nil)
		end		

		# Add a new custom watermark
		#
		# @param identifier [String] the identifier you want to give the custom watermark. It is important that this identifier is unique.
		# @param path [String] the absolute path of the watermark on your server. For instance C:/watermark/1.png
		# @param xpos [Integer] the horizontal position you want the screenshot to appear at: Left = 0, Center = 1, Right = 2
		# @param ypos [Integer] the vertical position you want the screenshot to appear at: Top = 0, Middle = 1, Bottom = 2
		# @return [Boolean] returns true if the watermark was successfully set
		# @raise [RuntimeError] if the GrabzIt service reports an error with the request it will be raised as a RuntimeError
		def add_watermark(identifier, path, xpos, ypos)
			if !File.file?(path)
				raise "File: " + path + " does not exist"
			end
			sig = encode(nil_check(@applicationSecret)+"|"+nil_check(identifier)+"|"+nil_int_check(xpos)+"|"+nil_int_check(ypos));

			boundary = '--------------------------'+Time.now.to_f.to_s

			url = "http://grabz.it/services/addwatermark.ashx"
			uri = URI.parse(url)

			file = File.open(path, "rb")
			data = file.read

			post_body = Array.new
			post_body << "\r\n--"+boundary+"\r\n"
			post_body << "Content-Disposition: form-data; name=\"watermark\"; filename=\""+File.basename(path)+"\"\r\nContent-Type: image/jpeg\r\n\r\n"
			post_body << data
			post_body << "\r\n--"+boundary+"\r\n"

			post_body << "Content-Disposition: form-data; name=\"key\"\r\n\r\n"
			post_body << CGI.escape(nil_check(@applicationKey))
			post_body << "\r\n--"+boundary+"\r\n"

			post_body << "Content-Disposition: form-data; name=\"identifier\"\r\n\r\n"
			post_body << CGI.escape(nil_check(identifier))
			post_body << "\r\n--"+boundary+"\r\n"

			post_body << "Content-Disposition: form-data; name=\"xpos\"\r\n\r\n"
			post_body << nil_check(xpos)
			post_body << "\r\n--"+boundary+"\r\n"

			post_body << "Content-Disposition: form-data; name=\"ypos\"\r\n\r\n"
			post_body << nil_check(ypos)
			post_body << "\r\n--"+boundary+"\r\n"

			post_body << "Content-Disposition: form-data; name=\"sig\"\r\n\r\n"
			post_body << sig
			post_body << "\r\n--"+boundary+"--\r\n"

			request = Net::HTTP::Post.new(url)
			request.content_type = "multipart/form-data, boundary="+boundary
			request.body = post_body.join

			response = Net::HTTP.new(uri.host, uri.port).start {|http| http.request(request) }	
			response_check(response)

			return (get_result_value(response.body(), "Result") == TrueString)		
		end

		# Delete a custom watermark
		#
		# @param identifier [String] the identifier of the custom watermark you want to delete
		# @return [Boolean] returns true if the watermark was successfully deleted
		# @raise [RuntimeError] if the GrabzIt service reports an error with the request it will be raised as a RuntimeError
		def delete_watermark(identifier)
			sig = encode(nil_check(@applicationSecret)+"|"+nil_check(identifier))               

			qs = "key=" +CGI.escape(nil_check(@applicationKey))+"&identifier="+CGI.escape(nil_check(identifier))+"&sig="+sig

			return (get_result_value(get(WebServicesBaseURL + "deletewatermark.ashx?" + qs), "Result") == TrueString)
		end	

		# This method calls the GrabzIt web service to take the screenshot.
		#
		# @param url [String] the URL that the screenshot should be made of
		# @param callback [String, nil] the handler the GrabzIt web service should call after it has completed its work
		# @param customId [String, nil] custom identifier that you can pass through to the screenshot webservice. This will be returned with the callback URL you have specified.	
		# @param browserWidth [Integer, nil] the width of the browser in pixels
		# @param browserHeight [Integer, nil] the height of the browser in pixels
		# @param width [Integer, nil] the width of the resulting thumbnail in pixels	
		# @param height [Integer, nil] the height of the resulting thumbnail in pixels	
		# @param format [String, nil] the format the screenshot should be in: bmp8, bmp16, bmp24, bmp, gif, jpg, png
		# @param delay [Integer, nil] the number of milliseconds to wait before taking the screenshot
		# @param targetElement [String, nil] the id of the only HTML element in the web page to turn into a screenshot
		# @return [String] returns the unique identifier of the screenshot. This can be used to get the screenshot with the get_result method
		# @raise [RuntimeError] if the GrabzIt service reports an error with the request it will be raised as a RuntimeError
		# @deprecated Use {#set_image_options} and {#save} instead.
		def take_picture(url, callback = nil, customId = nil, browserWidth = nil, browserHeight = nil, width = nil, height = nil, format = nil, delay = nil, targetElement = nil)
			set_image_options(url, customId, browserWidth, browserHeight, width, height, format, delay, targetElement)	
			return save(callback)
		end   

		# This method takes the screenshot and then saves the result to a file. WARNING this method is synchronous
		#
		# @param url [String] the URL that the screenshot should be made of
		# @param saveToFile [String] the file path that the screenshot should saved to
		# @param browserWidth [Integer, nil] the width of the browser in pixels
		# @param browserHeight [Integer, nil] the height of the browser in pixels
		# @param width [Integer, nil] the width of the resulting thumbnail in pixels
		# @param height [Integer, nil] the height of the resulting thumbnail in pixels	
		# @param format [String, nil] the format the screenshot should be in: bmp8, bmp16, bmp24, bmp, gif, jpg, png
		# @param delay [Integer, nil] the number of milliseconds to wait before taking the screenshot
		# @param targetElement [String, nil] the id of the only HTML element in the web page to turn into a screenshot
		# @example Synchronously save the screenshot to test.jpg
		#   save_picture('images/test.jpg')	
		# @return [Boolean] returns the true if it is successfull otherwise it throws an exception
		# @raise [RuntimeError] if the screenshot cannot be saved a RuntimeError will be raised that will contain an explanation
		# @deprecated Use {#set_image_options} and {#save_to} instead.
		def save_picture(url, saveToFile, browserWidth = nil, browserHeight = nil, width = nil, height = nil, format = nil, delay = nil, targetElement = nil)
			set_image_options(url, nil, browserWidth, browserHeight, width, height, format, delay, targetElement)	
			return save_to(saveToFile)
		end	

		# This method returns the image itself. If nothing is returned then something has gone wrong or the image is not ready yet.
		#
		# @param id [String] the id of the screenshot
		# @return [Object] returns the screenshot
		# @deprecated Use {#get_result} instead.	
		def get_picture(id)
			return get_result(id)
		end

		private
		def get_watermarks(identifier = nil)
			sig = encode(nil_check(@applicationSecret)+"|"+nil_check(identifier))               

			qs = "key=" +CGI.escape(nil_check(@applicationKey))+"&identifier="+CGI.escape(nil_check(identifier))+"&sig="+sig

			result = get(WebServicesBaseURL + "getwatermarks.ashx?" + qs)

			doc = REXML::Document.new(result)

			check_for_exception(doc)

			watermarks = Array.new

			xml_watemarks = doc.elements.to_a("//WebResult/WaterMarks/WaterMark")		
			xml_watemarks.each do |watemark|                	
				grabzItWaterMark = GrabzIt::WaterMark.new(watemark.elements["Identifier"].text, watemark.elements["XPosition"].text.to_i, watemark.elements["YPosition"].text.to_i, watemark.elements["Format"].text)
				watermarks << grabzItWaterMark
			end

			return watermarks
		end

		private
		def get(url)
			uri = URI.parse(url)
			response = Net::HTTP.start(uri.host, uri.port) { |http| http.get(uri.request_uri) }
			response_check(response)
			return response.body
		end

		private
		def response_check(response)
			statusCode = response.code.to_i
			if statusCode == 403
				raise GrabzItException.new(response.body, GrabzItException::NETWORK_DDOS_ATTACK)
			elsif statusCode >= 400
				raise GrabzItException.new("A network error occured when connecting to the GrabzIt servers.", GrabzItException::NETWORK_GENERAL_ERROR)
			end
		end

		private
		def b_to_str(bValue)
			if bValue
				return 1.to_s
			end
			return 0.to_s
		end

		private
		def nil_check(param)
			if param == nil
				return ""
			end
			return param
		end

		private
		def nil_int_check(param)
			return param.to_i.to_s
		end

		private
		def nil_float_check(param)
			val = param.to_f
			if ((val % 1) == 0)
				return val.to_i.to_s
			end
			
			return val.to_s
		end
		
		private
		def check_for_exception(doc)
			if (doc == nil)
				return
			end
			
			message = doc.root.elements["Message"].text()
			code  = doc.root.elements["Code"].text()
			
			if message != nil
				raise GrabzItException.new(message, code)
			end			
		end

		private
		def encode(text)
			return Digest::MD5.hexdigest(text.encode('ascii', {:invalid => :replace, :undef => :replace, :replace => '?'}))			
		end

		private 
		def get_result_value(result, field)
			doc = REXML::Document.new(result)
			
			value = doc.root.elements[field].text()

			check_for_exception(doc)

			return value
		end
	end
end