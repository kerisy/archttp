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
