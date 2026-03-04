import { clsx } from 'clsx';

type ButtonProps = {
  label: string;
  onClick?: () => void;
  variant?: 'primary' | 'secondary';
  disabled?: boolean;
  type?: 'button' | 'submit' | 'reset';
};

export function Button({
  label,
  onClick,
  variant = 'primary',
  disabled = false,
  type = 'button',
}: ButtonProps) {
  return (
    <button
      type={type}
      onClick={onClick}
      disabled={disabled}
      className={clsx(
        'inline-flex items-center justify-center rounded-md px-4 py-2 text-sm font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2',
        variant === 'primary' && 'bg-blue-600 text-white hover:bg-blue-700 focus:ring-blue-500',
        variant === 'secondary' &&
          'bg-gray-200 text-gray-900 hover:bg-gray-300 focus:ring-gray-500',
        disabled && 'cursor-not-allowed opacity-50',
      )}
    >
      {label}
    </button>
  );
}
