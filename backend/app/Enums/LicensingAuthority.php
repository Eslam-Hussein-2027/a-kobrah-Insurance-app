<?php

namespace App\Enums;

use App\Enums\Concerns\HasLabel;

/** Traffic department that issued the registration (جهة الترخيص). */
enum LicensingAuthority: string
{
    use HasLabel;

    case Tripoli = 'tripoli';
    case Benghazi = 'benghazi';
    case Misrata = 'misrata';
    case Zawiya = 'zawiya';
    case Sabha = 'sabha';
    case Bayda = 'bayda';
    case Tobruk = 'tobruk';
    case Derna = 'derna';
    case Sirte = 'sirte';
    case Khoms = 'khoms';
    case Zliten = 'zliten';
    case Gharyan = 'gharyan';
    case Ajdabiya = 'ajdabiya';
    case Marj = 'marj';
    case Sabratha = 'sabratha';
    case Zuwara = 'zuwara';
    case Tarhuna = 'tarhuna';
    case BaniWalid = 'bani_walid';
    case Kufra = 'kufra';
    case Ubari = 'ubari';
    case Ghat = 'ghat';
    case Murzuq = 'murzuq';
    case Jufra = 'jufra';
    case Nalut = 'nalut';
    case Yafran = 'yafran';
    case Other = 'other';

    public static function translationGroup(): string
    {
        return 'licensing_authority';
    }
}
