/*****************************************************************************
 * VLCLabel.m
 * MediaLibraryKit
 *****************************************************************************
 * Copyright (C) 2010-2018 VLC authors and VideoLAN
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

#import "VLCLabel.h"
#import "VLCUtils.h"

@interface VLCLabel ()
{
    medialibrary::LabelPtr _label;
}
@end

@implementation VLCLabel

- (int64_t)identifier
{
    return _label->id();
}

- (NSString *)name
{
    if (!_name) {
        _name = [[NSString alloc] initWithUTF8String:_label->name().c_str()];
    }
    return _name;
}

- (NSArray<VLCMedia *> *)files
{
    return [VLCUtils arrayFromMediaPtrVector:_label->files()];
}

@end

@implementation VLCLabel (Internal)

- (instancetype)initWithLabelPtr:(medialibrary::LabelPtr)labelPtr
{
    self = [super init];
    if (self) {
        _label = labelPtr;
    }
    return self;
}

- (medialibrary::LabelPtr)labelPtr
{
    return _label;
}

@end
