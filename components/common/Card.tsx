
import React from 'react';

interface CardProps {
  children: React.ReactNode;
  className?: string;
}

export const Card: React.FC<CardProps> = ({ children, className = '' }) => {
  return (
    <div className={`bg-white shadow-xl rounded-lg border border-sky-200 ${className}`}>
      {children}
    </div>
  );
};
    