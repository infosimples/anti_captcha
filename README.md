Developed by [Infosimples](https://infosimples.com).

# AntiCaptcha

AntiCaptcha is a Ruby API for Anti-Captcha - [Anti-Captcha.com](http://getcaptchasolution.com/ipuz16klxh).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'anti_captcha'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install anti_captcha

## Usage

1. **Create a client**

  ```ruby
  # Create a client
  client = AntiCaptcha.new('my_key')
  ```

2. **Solve Image CAPTCHA**

  There are two methods available:

  - `decode_image`: solves image CAPTCHAs. It doesn't raise exceptions.
  - `decode_image!`: solves image CAPTCHAs. It may raise an `AntiCaptcha::Error` if something goes wrong.

  If the solution is not available, an empty solution object will be returned.

  ```ruby
  solution = client.decode_image!(path: 'path/to/my/captcha/file')
  solution.text                # CAPTCHA solution.
  solution.url                 # Image URL.
  solution.task_result.task_id # The ID of the task.
  ```

  You can also specify *file*, *body* and *body64* when decoding an image.

  ```ruby
  client.decode_image!(file: File.open('path/to/my/captcha/file', 'rb'))

  client.decode_image!(body: File.open('path/to/my/captcha/file', 'rb').read)

  client.decode_image!(body64: Base64.encode64(File.open('path/to/my/captcha/file', 'rb').read))
  ```

  > Internally, the gem will always convert the image to body64 (binary base64 encoded).

3. **Report incorrectly solved image CAPTCHA for refund**

  It is only possible to report incorrectly solved image CAPTCHAs.

  ```ruby
  client.report_incorrect_image_catpcha!(task_id)
  ```

4. **Get your account balance**

  ```ruby
  client.get_balance!
  ```

5. **Get current stats of a queue.**

  Queue IDs:
  - `1` Standart ImageToText, English language.
  - `2` Standart ImageToText, Russian language.
  - `5` Recaptcha NoCaptcha tasks.
  - `6` Recaptcha Proxyless task.

  ```ruby
  client.get_queue_stats!(queue_id)
  ```

6. **Clickable CAPTCHAs (e.g. "No CAPTCHA reCAPTCHA")**

  This method allows you to solve CAPTCHAs similar to
  [reCAPTCHA v2](https://support.google.com/recaptcha/?hl=en#6262736).

  There are two methods available:

  - `decode_nocaptcha`: solves NoCaptcha CAPTCHAs. It doesn't raise exceptions.
  - `decode_nocaptcha!`: solves NoCaptcha CAPTCHAs. It may raise an `AntiCaptcha::Error` if something goes wrong.

  **Send the `website_key` and `website_url` parameters**

  This method requires no browser emulation. You can send two parameters that
  identify the website in which the CAPTCHA is found.

  ```ruby
  options = {
    website_key: 'xyz',
    website_url: 'http://example.com/example=1'
  }

  solution = client.decode_nocaptcha!(options)
  solution.g_recaptcha_response # Solution of the captcha
  ```

  The solution (`solution.g_recaptcha_response`) will be a code that validates
  the form, like the following:

  ```ruby
  "1JJHJ_VuuHAqJKxcaasbTsqw-L1Sm4gD57PTeaEr9-MaETG1vfu2H5zlcwkjsRoZoHxx6V9yUDw8Ig-hYD8kakmSnnjNQd50w_Y_tI3aDLp-s_7ZmhH6pcaoWWsid5hdtMXyvrP9DscDuCLBf7etLle8caPWSaYCpAq9DOTtj5NpSg6-OeCJdGdkjsakFUMeGeqmje87wSajcjmdjl_w4XZBY2zy8fUH6XoAGZ6AeCTulIljBQDObQynKDd-rutPvKNxZasDk-LbhTfw508g1lu9io6jnvm3kbAdnkfZ0x0PkGiUMHU7hnuoW6bXo2Yn_Zt5tDWL7N7wFtY6B0k7cTy73f8er508zReOuoyz2NqL8smDCmcJu05ajkPGt20qzpURMwHaw"
  ```

7. **FunCaptcha**

  This method allows you to solve FunCaptcha.

  **Send the `website_public_key` and `website_url` parameters**

  This method requires no browser emulation. You can send two parameters that
  identify the website in which the CAPTCHA is found.

  ```ruby
  options = {
    website_public_key: 'xyz',
    website_url: 'http://example.com/example=1',
    language_pool: '...'
  }

  solution = client.decode_fun_captcha(options)
  solution.token # Solution of the captcha
  ```

## Notes

#### Ruby dependencies

AntiCaptcha doesn't require specific dependencies. That saves you memory and
avoid conflicts with other gems.

#### Input image format

Any format you use in the decode method (file, path, body, body64) will always
be converted to a body64, which is a binary base64 encoded string. So, if you
already have this format available on your side, there's no need to do
convertions before calling the API.

> Our recomendation is to never convert your image format, unless needed. Let
> the gem convert internally. It may save you resources (CPU, memory and IO).

#### Versioning

AntiCaptcha gem uses [Semantic Versioning](http://semver.org/).

# License

MIT License. Copyright (C) 2011-2015 Infosimples. https://infosimples.com/
