<?php

/*
|--------------------------------------------------------------------------
| mPDF (carlos-meneses/laravel-mpdf)
|--------------------------------------------------------------------------
| Arabic shaping & RTL need an OpenType font with OTL enabled (useOTL=0xFF).
| Amiri (SIL Open Font License) is bundled in resources/fonts.
*/

return [
    'mode' => 'utf-8',
    'format' => 'A4',
    'default_font_size' => '11',
    'default_font' => 'amiri',
    'margin_left' => 14,
    'margin_right' => 14,
    'margin_top' => 14,
    'margin_bottom' => 22,
    'margin_header' => 0,
    'margin_footer' => 8,
    'orientation' => 'P',
    'title' => 'Motor Insurance Policy',
    'subject' => '',
    'author' => env('COMPANY_NAME_EN', 'Al Kobrah Insurance Co.'),
    'watermark' => '',
    'show_watermark' => false,
    'show_watermark_image' => false,
    'watermark_font' => 'amiri',
    'display_mode' => 'fullpage',
    'watermark_text_alpha' => 0.1,
    'watermark_image_path' => '',
    'watermark_image_alpha' => 0.2,
    'watermark_image_size' => 'D',
    'watermark_image_position' => 'P',
    'custom_font_dir' => resource_path('fonts/'),
    'custom_font_data' => [
        'amiri' => [
            'R' => 'Amiri-Regular.ttf',
            'B' => 'Amiri-Bold.ttf',
            'useOTL' => 0xFF,
            'useKashida' => 75,
        ],
    ],
    'auto_language_detection' => false,
    'temp_dir' => storage_path('framework/cache/mpdf'),
    'pdfa' => false,
    'pdfaauto' => false,
    'use_active_forms' => false,
];
