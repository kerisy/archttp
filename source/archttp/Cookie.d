module archttp.Cookie;

import std.uri;
import std.format;
import std.array;

class Cookie
{
	@safe:

	private
	{
		string _name;
		string _value;
		string _domain;
		string _path;
		string _expires;
		long   _maxAge;
		bool   _secure;
		bool   _httpOnly;
	}

	this(string name, string value = "", string path = "/", string domain = "", string expires = "", long maxAge = 3600, bool secure = false, bool httpOnly = false)
	{
		_name = name;

		this.value(value)
			.domain(domain)
			.path(path)
			.expires(expires)
			.maxAge(maxAge)
			.secure(secure)
			.httpOnly(httpOnly);
	}

	Cookie parse(string cookieString)
	{
		// if (!cookieString.length)
		// 	return null;

		// auto parts = cookieString.splitter(';');
		// auto idx = parts.front.indexOf('=');
		// if (idx == -1)
		// 	return null;

		// auto name = parts.front[0 .. idx].strip();
		// dst.m_value = parts.front[name.length + 1 .. $].strip();
		// parts.popFront();

		// if (!name.length)
		// 	return null;

		// foreach(part; parts) {
		// 	if (!part.length)
		// 		continue;

		// 	idx = part.indexOf('=');
		// 	if (idx == -1) {
		// 		idx = part.length;
		// 	}
		// 	auto key = part[0 .. idx].strip();
		// 	auto value = part[min(idx + 1, $) .. $].strip();

		// 	try {
		// 		if (key.sicmp("httponly") == 0) {
		// 			dst.m_httpOnly = true;
		// 		} else if (key.sicmp("secure") == 0) {
		// 			dst.m_secure = true;
		// 		} else if (key.sicmp("expires") == 0) {
		// 			// RFC 822 got updated by RFC 1123 (which is to be used) but is valid for this
		// 			// this parsing is just for validation
		// 			parseRFC822DateTimeString(value);
		// 			dst.m_expires = value;
		// 		} else if (key.sicmp("max-age") == 0) {
		// 			if (value.length && value[0] != '-')
		// 				dst.m_maxAge = value.to!long;
		// 		} else if (key.sicmp("domain") == 0) {
		// 			if (value.length && value[0] == '.')
		// 				value = value[1 .. $]; // the leading . must be stripped (5.2.3)

		// 			enforce!ConvException(value.all!(a => a >= 32), "Cookie Domain must not contain any control characters");
		// 			dst.m_domain = value.toLower; // must be lower (5.2.3)
		// 		} else if (key.sicmp("path") == 0) {
		// 			if (value.length && value[0] == '/') {
		// 				enforce!ConvException(value.all!(a => a >= 32), "Cookie Path must not contain any control characters");
		// 				dst.m_path = value;
		// 			} else {
		// 				dst.m_path = null;
		// 			}
		// 		} // else extension value...
		// 	} catch (DateTimeException) {
		// 	} catch (ConvException) {
		// 	}
		// 	// RFC 6265 says to ignore invalid values on all of these fields
		// }
		// return name;
		return null;
	}

	string name() const
	{
		return _name;
	}

	Cookie value(string value)
    {
		_value = encode(value);
		return this;
	}

	string value() const
	{
		return decode(_value);
	}
	
	Cookie domain(string value)
    {
		_domain = value;
		return this;
	}
	
	string domain() const
	{
		return _domain;
	}

	Cookie path(string value)
    {
		_path = value;
		return this;
	}
	
	string path() const
	{
		return _path;
	}

	Cookie expires(string value)
    {
		_expires = value;
		return this;
	}
	
	string expires() const
	{
		return _expires;
	}

	Cookie maxAge(long value)
    {
		_maxAge = value;
		return this;
	}

	long maxAge() const
	{
		return _maxAge;
	}

	Cookie secure(bool value)
    {
		_secure = value;
		return this;
	}

	bool secure() const
	{
		return _secure;
	}

	Cookie httpOnly(bool value)
    {
		_httpOnly = value;
		return this;
	}
	
	bool httpOnly() const
	{
		return _httpOnly;
	}

	override string toString()
	{
        auto text = appender!string;
		text ~= format!"%s=%s"(this._name, this.value());

		if (this._domain && this._domain != "")
    	{
			text ~= format!"; Domain=%s"(this._domain);
		}

		if (this._path != "")
    	{
			text ~= format!"; Path=%s"(this._path);
		}

		if (this.expires != "")
    	{
			text ~= format!"; Expires=%s"(this._expires);
		}

		if (this.maxAge)
			text ~= format!"; Max-Age=%s"(this._maxAge);

		if (this.secure)
			text ~= "; Secure";

		if (this.httpOnly)
			text ~= "; HttpOnly";

		return text[];
	}
}
