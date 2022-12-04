# AntiCaptcha

AntiCaptcha is a Ruby API for Anti-Captcha - [Anti-Captcha.com](http://getcaptchasolution.com/ipuz16klxh)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'anti_captcha'
```

And then execute:

```bash
$ bundle
````

Or install it yourself as:

```bash
$ gem install anti_captcha
````

## Usage

### 1. Create a client

```ruby
client = AntiCaptcha.new('my_key')
```

### 2. Solve a CAPTCHA

There are two types of methods available: `decode_*` and `decode_*!`:

- `decode_*` does not raise exceptions.
- `decode_*!` may raise a `AntiCaptcha::Error` if something goes wrong.

If the solution is not available, an empty solution object will be returned.

```ruby
solution = client.decode_image!(path: 'path/to/my/captcha/file')
solution.text                # CAPTCHA solution
solution.url                 # Image URL
solution.task_result.task_id # The task ID
```

#### Image CAPTCHA

You can specify `file`, `body` or `body64` when decoding an image.

```ruby
client.decode_image!(file: File.open('path/to/my/captcha/file', 'rb'))
client.decode_image!(body: File.open('path/to/my/captcha/file', 'rb').read)
client.decode_image!(body64: Base64.encode64(File.open('path/to/my/captcha/file', 'rb').read))
```

#### reCAPTCHA v2

```ruby
solution = client.decode_recaptcha_v2!(
  website_key:    'xyz',
  website_url:    'http://example.com/example=1',
  # proxy_type:     'http',                   # OPTIONAL
  # proxy_address:  '127.0.0.1',              # OPTIONAL
  # proxy_port:     '8080',                   # OPTIONAL
  # proxy_login:    'proxyLoginHere',         # OPTIONAL
  # proxy_password: 'proxyPasswordHere',      # OPTIONAL
  # user_agent:     'MODERN_USER_AGENT_HERE', # OPTIONAL
)

solution.g_recaptcha_response
"03AOPBWq_RPO2vLzyk0h8gH0cA2X4v3tpYCPZR6Y4yxKy1s3Eo7CHZRQntxrd..."
```

*Parameters:*

- `website_key`: the Google website key for the reCAPTCHA.
- `website_url`: the URL of the page with the reCAPTCHA challenge.
- `proxy_type`: optional parameter. Proxy connection protocol.
- `proxy_address`: optional parameter. The proxy address.
- `proxy_port`: optional parameter. The proxy port.
- `proxy_login`: optional parameter. The proxy login.
- `proxy_password`: optional parameter. The proxy password.
- `user_agent`: optional parameter. The user agent.

#### reCAPTCHA v3

```ruby
solution = client.decode_recaptcha_v3!(
  website_key:   'xyz',
  website_url:   'http://example.com/example=1',
  page_action:   'myverify',
  min_score:     0.3,   # OPTIONAL
  # is_enterprise: false, # OPTIONAL
)

solution.g_recaptcha_response
"03AOPBWq_RPO2vLzyk0h8gH0cA2X4v3tpYCPZR6Y4yxKy1s3Eo7CHZRQntxrd..."
```

*Parameters:*

- `website_key`: the Google website key for the reCAPTCHA.
- `website_url`: the URL of the page with the reCAPTCHA challenge.
- `action`: the action name used by the CAPTCHA.
- `min_score`: optional parameter. The minimal score needed for the CAPTCHA resolution. Defaults to `0.3`.
- `is_enterprise`: optional parameter. Set to `true` if you are solving a reCAPTCHA v3 Enterprise. Defaults to `false`.

> About the `action` parameter: in order to find out what this is, you need to inspect the JavaScript
> code of the website looking for a call to the `grecaptcha.execute` function.
>
> ```javascript
> // Example
> grecaptcha.execute('6Lc2fhwTAAAAAGatXTzFYfvlQMI2T7B6ji8UVV_f', { action: "examples/v3scores" })
> ````

> About the `min_score` parameter: it's strongly recommended to use a minimum score of `0.3` as higher
> scores are rare.

#### hCaptcha

```ruby
solution = client.decode_h_captcha!(
  website_key:    'xyz',
  website_url:    'http://example.com/example=1',
  # proxy_type:     'http',                   # OPTIONAL
  # proxy_address:  '127.0.0.1',              # OPTIONAL
  # proxy_port:     '8080',                   # OPTIONAL
  # proxy_login:    'proxyLoginHere',         # OPTIONAL
  # proxy_password: 'proxyPasswordHere',      # OPTIONAL
  # user_agent:     'MODERN_USER_AGENT_HERE', # OPTIONAL
)

solution.token
"P0_eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwYXNza2V5IjoiNnpWV..."

# Or

solution.g_recaptcha_response # Deprecated
"P0_eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwYXNza2V5IjoiNnpWV..."
```

*Parameters:*

- `website_key`: the site key for the hCatpcha.
- `website_url`: the URL of the page with the hCaptcha challenge.
- `proxy_type`: optional parameter. Proxy connection protocol.
- `proxy_address`: optional parameter. The proxy address.
- `proxy_port`: optional parameter. The proxy port.
- `proxy_login`: optional parameter. The proxy login.
- `proxy_password`: optional parameter. The proxy password.
- `user_agent`: optional parameter. The user agent.

#### FunCaptcha

```ruby
solution = client.decode_fun_captcha!(
  website_public_key: 'xyz',
  website_url:        'http://example.com/example=1',
  # proxy_type:         'http',                   # OPTIONAL
  # proxy_address:      '127.0.0.1',              # OPTIONAL
  # proxy_port:         '8080',                   # OPTIONAL
  # proxy_login:        'proxyLoginHere',         # OPTIONAL
  # proxy_password:     'proxyPasswordHere',      # OPTIONAL
  # user_agent:         'MODERN_USER_AGENT_HERE', # OPTIONAL
)

solution.token
"380633616d817f2b8.2351188603|r=ap-southeast-2|met..."
```

*Parameters:*

- `website_key`: the site key for the hCatpcha.
- `website_url`: the URL of the page with the hCaptcha challenge.
- `proxy_type`: optional parameter. Proxy connection protocol.
- `proxy_address`: optional parameter. The proxy address.
- `proxy_port`: optional parameter. The proxy port.
- `proxy_login`: optional parameter. The proxy login.
- `proxy_password`: optional parameter. The proxy password.
- `user_agent`: optional parameter. The user agent.

#### Geetest

```ruby
solution = client.decode_geetest!(
  website_url:         'http://mywebsite.com/geetest/test.php',
  gt:                  '874703612e5cac182812a00e273aad0d',
  challenge:           'a559b82bca2c500101a1c8a4f4204742',
  # proxy_type:         'http',                   # OPTIONAL
  # proxy_address:      '127.0.0.1',              # OPTIONAL
  # proxy_port:         '8080',                   # OPTIONAL
  # proxy_login:        'proxyLoginHere',         # OPTIONAL
  # proxy_password:     'proxyPasswordHere',      # OPTIONAL
  # user_agent:         'MODERN_USER_AGENT_HERE', # OPTIONAL
)

solution.v3['challenge']
"3c1c5153aa48011e92883aed820069f3hj"

solution.v3['validate']
"47ad5a0a6eb98a95b2bcd9e9eecc8272"

solution.v3['seccode']
"83fa4f2d23005fc91c3a015a1613f803|jordan"

# Or

solution.v4['captcha_id']
"fcd636b4514bf7ac4143922550b3008b"

solution.v4['lot_number']
"354ab6dd4e594fdc903074c4d8d37b24"

solution.v4['pass_token']
"b645946a654e60218c7922b74b3b5ee8e8717e8fd3cd51..."

solution.v4['gen_time']
"1649921519"

solution.v4['captcha_output']
"cFPIALDXSop8Ri2mPABbRWzNBs86N8D4vNUTuVa7wN7E..."
```
*Parameters:*

- `website_url`: URL of a target web page. It can be located anywhere on the web site, even in a member's area.
- `gt`: the domain's public key.
- `challenge`: changing token key. Make sure you grab a fresh one for each captcha.
- `geetest_api_server_subdomain`: optional parameter. API subdomain. May be required for some implementations.
- `geetest_get_lib`: optional parameter. Required for some implementations. Send the JSON encoded into a string. The value can be traced in the browser's developer tools. Put a breakpoint before calling the "initGeetest" function.
- `version`: optional parameter. Version number. Default version is 3. Supported versions: 3 and 4.
- `init_parameters`: optional parameter. Additional initialization parameters for version 4.
- `proxy_type`: optional parameter. Proxy connection protocol.
- `proxy_address`: optional parameter. The proxy address.
- `proxy_port`: optional parameter. The proxy port.
- `proxy_login`: optional parameter. The proxy login.
- `proxy_password`: optional parameter. The proxy password.
- `user_agent`: optional parameter. The user agent.

### 3. Report an incorrectly solved image CAPTCHA for a refund

It is only possible to report incorrectly solved image CAPTCHAs.

```ruby
client.report_incorrect_image_catpcha!(task_id)
```

### 4. Get your account balance

```ruby
client.get_balance!
```

### 5. Get current stats of a queue.

Queue IDs:

- `1`  Standart ImageToText, English language
- `2`  Standart ImageToText, Russian language
- `5`  Recaptcha NoCaptcha tasks
- `6`  Recaptcha Proxyless task
- `7`  Funcaptcha task
- `10` Funcaptcha Proxyless task
- `12` GeeTest with proxy
- `13` GeeTest without proxy
- `18` Recaptcha V3 s0.3
- `19` Recaptcha V3 s0.7
- `20` Recaptcha V3 s0.9
- `21` hCaptcha with proxy
- `22` hCaptcha without proxy
- `23` Recaptcha Enterprise V2 with proxy
- `24` Recaptcha Enterprise V2 without proxy
- `25` AntiGateTask

```ruby
client.get_queue_stats!(queue_id)
```

## Notes

### Ruby dependencies

AntiCaptcha doesn't require specific dependencies. That saves you memory and
avoid conflicts with other gems.

### Input image format

Any format you use in the `decode_image!` method (`file`, `path`, `body` or `body64`)
will always be converted to a `body64`, which is a base64-encoded binary string.
So, if you already have this format on your end, there is no need for convertions
before calling the API.

> Our recomendation is to never convert your image format, unless needed. Let
> the gem convert internally. It may save you resources (CPU, memory and IO).

### Versioning

AntiCaptcha gem uses [Semantic Versioning](http://semver.org/).

# License

MIT License. Copyright (C) 2011-2022 Infosimples. https://infosimples.com/
