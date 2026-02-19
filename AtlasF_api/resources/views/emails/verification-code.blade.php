<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Verify your account</title>
</head>
<body style="font-family: Arial, sans-serif; background:#f4f4f4; padding:20px;">

<div style="max-width:500px; margin:auto; background:white; padding:20px; border-radius:10px; text-align:center;">

    <h2 style="color:#2c3e50;">Welcome to AtlasFix 👋</h2>

    <p>Hello <strong>{{ $name }}</strong>,</p>

    <p>Use the verification code below to activate your account.</p>

    <div style="font-size:32px; letter-spacing:5px; margin:20px 0; font-weight:bold;">
        {{ $code }}
    </div>

    <p style="color:gray;">This code will expire in 10 minutes.</p>

    <hr>

    <p style="font-size:12px; color:gray;">
        If you did not create an account, you can safely ignore this email.
    </p>

</div>

</body>
</html>
