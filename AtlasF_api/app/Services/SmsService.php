<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class SmsService
{
    private string $apiKey;
    private string $baseUrl;
    private string $sender;

    public function __construct()
    {
        $this->apiKey  = config('services.infobip.api_key');
        $this->baseUrl = config('services.infobip.base_url');
        $this->sender  = config('services.infobip.sender');
    }

    public function send(string $phone, string $message): bool
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'App ' . $this->apiKey,
                'Content-Type'  => 'application/json',
                'Accept'        => 'application/json',
            ])->post($this->baseUrl . '/sms/2/text/advanced', [
                'messages' => [
                    [
                        'destinations' => [['to' => $phone]],
                        'from'         => $this->sender,
                        'text'         => $message,
                    ]
                ]
            ]);

            if ($response->failed()) {
                Log::error('InfoBip SMS failed', [
                    'phone'  => $phone,
                    'status' => $response->status(),
                    'body'   => $response->body(),
                ]);
                return false;
            }

            return true;

        } catch (\Throwable $e) {
            Log::error('InfoBip SMS exception', [
                'phone' => $phone,
                'error' => $e->getMessage(),
            ]);
            return false;
        }
    }

    public function sendVerificationCode(string $phone, string $code): bool
    {
        $message = "Votre code de vérification est : {$code}. Valable 10 minutes.";
        return $this->send($phone, $message);
    }

    public function sendResetCode(string $phone, string $code): bool
    {
        $message = "Votre code de réinitialisation est : {$code}. Valable 10 minutes.";
        return $this->send($phone, $message);
    }
}