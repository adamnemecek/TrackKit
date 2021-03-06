//
//  TKDetectorView.m
//  TrackKit
//
//  Created by Kyle Reynolds on 5/15/14.
//  Copyright (c) 2014 Kyle Reynolds. All rights reserved.
//

#import "TKDetectorView.h"
#import "TKDetectorView+regions.h"
#import "TKDetectorView+physics.h"
#import "NSTouch+physics.h"
#import <Foundation/Foundation.h>
#import "NSScreen+PointConversion.h"

@implementation TKDetectorView

- (id)initWithFrame:(NSRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:[self visibleRect] options: NSTrackingMouseEnteredAndExited |NSTrackingInVisibleRect |NSTrackingActiveAlways owner:self userInfo:nil];
        font_attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [NSNumber numberWithFloat:1.0], NSBaselineOffsetAttributeName, nil, NSForegroundColorAttributeName, [NSColor whiteColor]];        point_size = self.frame.size.height/6;
        visible = true;
        trackpad_regions = [[NSMutableDictionary alloc] init];
        font = [NSFont fontWithName:@"Avenir Heavy" size:point_size/10];

        
        [self addTrackingArea:trackingArea];
        [self setNeedsDisplay:YES];
        [self setAcceptsTouchEvents:YES];
        [self setWantsRestingTouches:YES];
        [self becomeFirstResponder];
        
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    
    CGPoint framerelative = [self convertToScreenFromLocalPoint:CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)) relativeToView:self.superview];
    CGWarpMouseCursorPosition(framerelative);
    
    [[NSColor whiteColor] setFill];
    NSRectFill(dirtyRect);
    
    NSRect r = NSMakeRect(10, 10, 10, 10);
    NSBezierPath *bp = [NSBezierPath bezierPathWithRect:r];
    NSColor *color = [NSColor whiteColor];
    [color set];
    [bp stroke];
    
    [self verbose];
    [self drawRegions];
    [self regionIntersections];
    [super drawRect:dirtyRect];
}

//verbose mode draws the touch points in the TKDetectorView.
-(void)verbose {
    
    if(visible) {
        //Fast enumeration over contents of an nsdictionary requires accessing its allKeys.
        for(NSTouch* x in [touch_identities allValues]) {
           
            CGRect to_draw = CGRectMake(x.normalizedPosition.x*self.bounds.size.width, x.normalizedPosition.y*self.bounds.size.height, point_size, point_size);
            NSBezierPath* square = [NSBezierPath bezierPath];
            [square appendBezierPathWithRect:to_draw];
            [[NSColor whiteColor] setFill];
            [[NSColor blackColor] setStroke];
            [square stroke];
            
            [[NSString stringWithFormat:@"# = %lu\n dir = %.2lfº\n avg vel = %.2lf mm/s\n, inst. vel = %.2lf mm/s",
              [[touch_identities allValues] indexOfObject:x],
              [self direction:x],
              [self velocity:x],
              [self instantaneousVelocity:x]]
             drawInRect:to_draw withAttributes:font_attributes];
        }
    }
}

//We need a touchesBegan event for taps.
-(void)touchesBeganWithEvent:(NSEvent *)event {
    
    touch_identities = [[NSMutableDictionary alloc] init];
    for(NSTouch* touch in [event touchesMatchingPhase:NSTouchPhaseAny inView:self]) {
        [touch_identities setObject:touch forKey:[touch identity]];
    }
    [self phys_record];
}

-(void)touchesMovedWithEvent:(NSEvent *)event {
    
   for(NSTouch* touch in [event touchesMatchingPhase:NSTouchPhaseAny inView:self]) {
        [touch_identities setObject:touch forKey:[touch identity]];
    }
    [self phys_record];
}

-(void)touchesEndedWithEvent:(NSEvent *)event {
    /*(for(NSTouch* touch in [event touchesMatchingPhase:NSTouchPhaseEnded inView:self]) {
        //[touch_identities setObject:touch forKey:[touch identity]];
        [touch_identities removeObjectForKey:[touch identity]];
    }*/
    for(NSTouch* touch in [event touchesMatchingPhase:NSTouchPhaseAny inView:self]) {
        [touch_identities setObject:touch forKey:[touch identity]];
    }
    [self phys_record];
}

-(NSMutableDictionary*)touches {
    return touch_identities;
}

-(BOOL)isBeingTouched {
    //isBeingTouched counts for touches whose phase is not ended
    

    for(NSTouch* touch in [touch_identities allValues]) {
        //NSLog(@"touch phase %d",[touch phase]);
        
        //NSLog(@"example of a touch phase: %d %d %d", NSTouchPhaseStationary, NSTouchPhaseMoved, NSTouchPhaseBegan);
        if([touch phase] == NSTouchPhaseStationary) {
            return 1;
        }
        if([touch phase] == NSTouchPhaseMoved) {
            return 1;
        }
        if([touch phase] == NSTouchPhaseBegan) {
            return 1;
        }
    }
    return 0;
}

-(BOOL)hasNumberOfTouchings:(NSUInteger)userNumber {
    NSUInteger num = 0;
    for(NSTouch* touch in [touch_identities allValues]) {
        //NSLog(@"touch phase %d",[touch phase]);
        
        //NSLog(@"example of a touch phase: %d %d %d", NSTouchPhaseStationary, NSTouchPhaseMoved, NSTouchPhaseBegan);
        if([touch phase] == NSTouchPhaseStationary) {
            num++;
        } else
        if([touch phase] == NSTouchPhaseMoved) {
            num++;
        } else
        if([touch phase] == NSTouchPhaseBegan) {
            num++;
        }
    }
    return (num == userNumber);
}

-(NSTouch*)firstFinger {
    return [[touch_identities allValues] objectAtIndex:0];
}

-(NSTouch*)fingerNumber:(NSUInteger)userFingerNumber {
    if([[touch_identities allValues] count] < userFingerNumber){
        return [self firstFinger];
    }
    return [[touch_identities allValues] objectAtIndex:userFingerNumber];
}

-(NSTouch*)firstFling {
    for(NSTouch* touch in [touch_identities allValues]) {
        NSLog(@"speed %.2lf, touchphase %d", [self instantaneousVelocity:touch], [touch phase]);
    }
    for(NSTouch* touch in [touch_identities allValues]) {
        if([touch phase] == NSTouchPhaseEnded) {
            return touch;
        }
    }
    return nil;
}
//(C) Nial Giacomelli
- (NSPoint)convertToScreenFromLocalPoint:(NSPoint)point relativeToView:(NSView *)view {
    
	NSScreen *currentScreen = [NSScreen currentScreenForMouseLocation];
	if(currentScreen)
	{
		NSPoint windowPoint = [view convertPoint:point toView:nil];
		NSPoint screenPoint = [[view window] convertBaseToScreen:windowPoint];
		NSPoint flippedScreenPoint = [currentScreen flipPoint:screenPoint];
		flippedScreenPoint.y += [currentScreen frame].origin.y;
        
		return flippedScreenPoint;
	}
    
	return NSZeroPoint;
}
@end
