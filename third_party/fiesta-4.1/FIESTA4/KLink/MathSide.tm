/*
    This file is a part of the program QLink.
    Copyright (C) Alexander Smirnov <asmirnov@particle.uni-karlsruhe.de>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License version 2 as
    published by the Free Software Foundation.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

	------------------------------------------------------------------
	
*/

:Begin:
:Function:      qopen
:Pattern:       QOpen[s_String]
:Arguments:     {s}
:ArgumentTypes: {String}
:ReturnType:    Manual
:End:

:Begin:
:Function:      qread
:Pattern:       QRead[s_String]
:Arguments:     {s}
:ArgumentTypes: {String}
:ReturnType:    Manual
:End:

:Begin:
:Function:      qremovedatabase
:Pattern:       QRemoveDatabase[s_String]
:Arguments:     {s}
:ArgumentTypes: {String}
:ReturnType:    Manual
:End:


:Begin:
:Function:      qput
:Pattern:       QPut[s_String,key_String,value_String]
:Arguments:     {s,key,value}
:ArgumentTypes: {String,String,String}
:ReturnType:    Manual
:End:



:Begin:
:Function:      qget
:Pattern:       QGet[s_String,key_String]
:Arguments:     {s,key}
:ArgumentTypes: {String,String}
:ReturnType:    Manual
:End:

:Begin:
:Function:      qsafeget
:Pattern:       QSafeGet[s_String,key_String]
:Arguments:     {s,key}
:ArgumentTypes: {String,String}
:ReturnType:    Manual
:End:

:Begin:
:Function:      qcheck
:Pattern:       QCheck[s_String,key_String]
:Arguments:     {s,key}
:ArgumentTypes: {String,String}
:ReturnType:    Manual
:End:


:Begin:
:Function:      qremove
:Pattern:       QRemove[s_String,key_String]
:Arguments:     {s,key}
:ArgumentTypes: {String,String}
:ReturnType:    Manual
:End:


:Begin:
:Function:      qclose
:Pattern:       QClose[s_String]
:Arguments:     {s}
:ArgumentTypes: {String}
:ReturnType:    Manual
:End:



:Begin:
:Function:      qrepair
:Pattern:       QRepair[s_String]
:Arguments:     {s}
:ArgumentTypes: {String}
:ReturnType:    Manual
:End:

:Begin:
:Function:      qlist
:Pattern:       QList[s_String]
:Arguments:     {s}
:ArgumentTypes: {String}
:ReturnType:    Manual
:End:

:Begin:
:Function:      qsize
:Pattern:       QSize[s_String]
:Arguments:     {s}
:ArgumentTypes: {String}
:ReturnType:    Manual
:End:

:Begin:
:Function:      qsetbucketsize
:Pattern:       QSetBucketSize[i_Integer]
:Arguments:     {i}
:ArgumentTypes: {Integer}
:ReturnType:    Manual
:End:

:Begin:
:Function:      qsetcompressionon
:Pattern:       QSetCompressionOn[]
:Arguments:     {}
:ArgumentTypes: {}
:ReturnType:    Manual
:End:

:Begin:
:Function:      qsetcompressionoff
:Pattern:       QSetCompressionOff[]
:Arguments:     {}
:ArgumentTypes: {}
:ReturnType:    Manual
:End:


:Begin:
:Function:      qsetautobucketon
:Pattern:       QSetAutoBucketOn[]
:Arguments:     {}
:ArgumentTypes: {}
:ReturnType:    Manual
:End:

:Begin:
:Function:      qsetautobucketoff
:Pattern:       QSetAutoBucketOff[]
:Arguments:     {}
:ArgumentTypes: {}
:ReturnType:    Manual
:End:


:Begin:
:Function:      qsetnolock
:Pattern:       QSetNoLock[]
:Arguments:     {}
:ArgumentTypes: {}
:ReturnType:    Manual
:End:

:Begin:
:Function:      qsetlock
:Pattern:       QSetLock[]
:Arguments:     {}
:ArgumentTypes: {}
:ReturnType:    Manual
:End:


:Evaluate:      QSize::usage = "QSize[i] sets the bucket size to 2^i"
:Evaluate:      QOpen::usage = "QOpen[file] opens a connection to the database"
:Evaluate:      QRead::usage = "QOpen[file] opens a connection to the database for reading"
:Evaluate:      QRemoveDatabase::usage = "QRemoveDatabase[file] removes a closed database completely"
:Evaluate:      QRepair::usage = "QRepair[file] attempts to repair the database"
:Evaluate:      QList::usage = "QList[file] lists all entries in the database"
:Evaluate:      QClose::usage = "QClose[file] closes the connection"
:Evaluate:      QRemove::usage = "QRemove[file,key] removes the value for key in the database"
:Evaluate:      QGet::usage = "QGet[file,key] retrieves the value for key in the database"
:Evaluate:      QSafeGet::usage = "QSafeGet[file,key] works as QGet but produces no error message if there is no entry in the database, returning False instead"
:Evaluate:      QPut::usage = "QPut[file,key,value] creates an entry with key and value in the database"
:Evaluate:      QCheck::usage = "QCheck[file,key] answers if there is an entry with key in the database"
:Evaluate:      QSize::usage = "QSize[file] returns the total size of the database"
:Evaluate:      QRead::failed = "`1`"
:Evaluate:      QSize::failed = "`1`"
:Evaluate:      QPut::failed = "`1`"
:Evaluate:      QCheck::failed = "`1`"
:Evaluate:      QRepair::failed = "`1`"
:Evaluate:      QOpen::failed = "`1`"
:Evaluate:      QList::failed = "`1`"
:Evaluate:      QClose::failed = "`1`"
:Evaluate:      QRemove::failed = "`1`"
:Evaluate:      QRemoveDatabase::failed = "`1`"
:Evaluate:      QGet::failed = "`1`"
:Evaluate:      QSetBucketSize::failed = "`1`"
:Evaluate:      QSafeGet::failed = "`1`"
:Evaluate:		WriteString[$Output,"KLink created (2013 version)! You can read information on QOpen, QRead, QRemoveDatabase, QClose, QList, QSize, QPut, QGet, QSafeGet, QCheck and QRemove\n"];
