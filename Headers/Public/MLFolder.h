/*****************************************************************************
 * MLFolder.h
 * MediaLibraryKit
 *****************************************************************************
 * Copyright (C) 2010-2017 VLC authors and VideoLAN
 * $Id$
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/

@interface MLFolder : NSObject

/**
 * @brief mrl Returns the full mrl for this folder.
 * Caller is responsible for checking isPresent() beforehand, as we
 * can't compute an for a folder that is/was present on a removable storage
 * or network share that has been unplugged
 * If for some reasons we can't compute the MRL, an empty string wil
 * @return The folder's mrl
 */
@property (nonatomic, copy) NSString *mrl;

- (instancetype)init NS_UNAVAILABLE;

- (int64_t)identifier;
- (NSString *)mrl;
- (BOOL)isPresent;

@end
