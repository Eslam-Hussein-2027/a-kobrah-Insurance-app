<?php

namespace App\Services\Sms\Resala;

/**
 * The "type" field of a Resala error response. Code branches on this, never on the localized message.
 */
enum ResalaErrorType: string
{
    case AccountExpired = 'AccountExpired';
    case InsufficientCredit = 'InsufficientCredit';
    case BadRequest = 'BadRequest';
    case Unauthorized = 'Unauthorized';
    case TokenExpired = 'TokenExpired';
    case Forbidden = 'Forbidden';
    case NotFound = 'NotFound';
    case InputValidation = 'InputValidation';

    /** An error response without a known "type". */
    case Unknown = 'Unknown';

    /** No response at all (DNS, timeout, TLS...). The message may or may not have been sent. */
    case ConnectionFailed = 'ConnectionFailed';

    /** Problems with our Resala account that someone at the company has to fix (top up, renew, new key). */
    public function needsAttention(): bool
    {
        return in_array($this, [self::AccountExpired, self::InsufficientCredit, self::Unauthorized, self::TokenExpired, self::Forbidden], true);
    }
}
