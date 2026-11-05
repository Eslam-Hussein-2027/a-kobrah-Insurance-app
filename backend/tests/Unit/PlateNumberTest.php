<?php

namespace Tests\Unit;

use App\Support\Digits;
use App\Support\PhoneNumber;
use App\Support\PlateNumber;
use PHPUnit\Framework\TestCase;

class PlateNumberTest extends TestCase
{
    public function test_libyan_plates_are_normalized(): void
    {
        $this->assertSame('5-123456', PlateNumber::format(' ٥ - ١٢٣٤٥٦ '));
        $this->assertTrue(PlateNumber::equals('5-123456', '٥ ١٢٣٤٥٦'));
        $this->assertTrue(PlateNumber::equals('5-123456', '5123456'));
        $this->assertFalse(PlateNumber::equals('5-123456', '6-123456'));
    }

    public function test_format_collapses_spaces_and_converts_digits(): void
    {
        $this->assertSame('ق ط ن 1234', PlateNumber::format('  ق   ط ن  ١٢٣٤ '));
        $this->assertSame('ABC 123', PlateNumber::format('abc 123'));
    }

    public function test_equality_ignores_spacing_dashes_and_digit_script(): void
    {
        $this->assertTrue(PlateNumber::equals('ق ط ن 1234', 'قطن١٢٣٤'));
        $this->assertTrue(PlateNumber::equals('ق-ط-ن-1234', 'ق ط ن 1234'));
        $this->assertFalse(PlateNumber::equals('ق ط ن 1234', 'ق ط ن 1235'));
    }

    public function test_libyan_phone_numbers_are_converted_to_local_format(): void
    {
        foreach (['+218911234567', '00218911234567', '218911234567', '+218 91-123 4567', '٠٩١١٢٣٤٥٦٧', '091 123 4567'] as $input) {
            $this->assertSame('0911234567', PhoneNumber::normalize($input, '218'), $input);
        }

        $this->assertSame('0925441206', PhoneNumber::normalize('0925441206', '218'));
    }

    public function test_digits_are_normalized_from_arabic_and_persian(): void
    {
        $this->assertSame('01012345678', Digits::toWestern('٠١٠١٢٣٤٥٦٧٨'));
        $this->assertSame('123', Digits::toWestern('۱۲۳'));
        $this->assertSame(42, Digits::toWestern(42));
    }
}
