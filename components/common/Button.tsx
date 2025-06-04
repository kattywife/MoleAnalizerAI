
import React from 'react';

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'outline';
  children: React.ReactNode;
}

export const Button: React.FC<ButtonProps> = ({ variant = 'primary', children, className = '', ...props }) => {
  let baseStyle = "px-4 py-2 rounded-md font-semibold focus:outline-none focus:ring-2 focus:ring-opacity-50 transition-colors duration-150 ease-in-out flex items-center justify-center";
  
  if (props.disabled) {
    baseStyle += " opacity-50 cursor-not-allowed";
  }

  let variantStyle = '';
  switch (variant) {
    case 'primary':
      variantStyle = props.disabled 
        ? "bg-red-400 text-white" 
        : "bg-red-700 text-white hover:bg-red-800 focus:ring-red-500";
      break;
    case 'secondary':
      variantStyle = props.disabled
        ? "bg-sky-200 text-sky-600"
        : "bg-sky-500 text-white hover:bg-sky-600 focus:ring-sky-400";
      break;
    case 'outline':
      variantStyle = props.disabled
        ? "border border-gray-300 text-gray-400"
        : "border border-red-700 text-red-700 hover:bg-red-50 focus:ring-red-500";
      break;
  }

  return (
    <button className={`${baseStyle} ${variantStyle} ${className}`} {...props}>
      {children}
    </button>
  );
};
    