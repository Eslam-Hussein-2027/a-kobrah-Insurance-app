<?php

namespace App\Enums\Concerns;

/**
 * Adds translated labels to backed enums.
 * Labels live in lang/{locale}/enums.php under the group returned by translationGroup().
 */
trait HasLabel
{
    abstract public static function translationGroup(): string;

    public function label(): string
    {
        return __('enums.'.static::translationGroup().'.'.$this->value);
    }

    /**
     * @return array{value: string, label: string}
     */
    public function toArray(): array
    {
        return ['value' => $this->value, 'label' => $this->label()];
    }

    /**
     * @return list<string>
     */
    public static function values(): array
    {
        return array_column(self::cases(), 'value');
    }
}
