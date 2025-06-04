
import React from 'react';
import { UI_TEXT } from '../constants';

export const Header: React.FC = () => {
  return (
    <header className="bg-red-800 text-white p-3 sm:p-4 shadow-md">
      <div className="container mx-auto flex justify-between items-center">
        <div className="flex items-center">
          <span className="bg-white text-red-800 font-bold text-lg sm:text-xl px-1.5 sm:px-2 py-0.5 sm:py-1 rounded mr-1.5 sm:mr-2">SS</span>
          <h1 className="text-xl sm:text-2xl font-semibold">{UI_TEXT.appName}</h1>
        </div>
        <div className="flex items-center space-x-3">
          {/* Doctor Icon Removed */}
        </div>
      </div>
    </header>
  );
};
