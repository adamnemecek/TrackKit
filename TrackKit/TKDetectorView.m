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

@implementation TKDetectorView

- (id)initWithFrame:(NSRect)frame {

    self = [super initWithFrame:frame];
    if (self) {
        NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:[self visibleRect] options: NSTrackingMouseEnteredAndExited |NSTrackingInVisibleRect |NSTrackingActiveAlways owner:self userInfo:nil];
       
        [self addTrackingArea:trackingArea];
        [self setNeedsDisplay:YES];
        [self setAcceptsTouchEvents:YES];
        [self setWantsRestingTouches:YES];
        [self becomeFirstResponder];
        point_size = 64.0f;
        visible = true;
        trackpad_regions = [[NSMutableDictionary alloc] init];
        framerelative = self.frame.origin;
        font = [NSFont fontWithName:@"Avenir" size:6.0];
        font_attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [NSNumber numberWithFloat:1.0], NSBaselineOffsetAttributeName, nil, NSForegroundColorAttributeName, [NSColor whiteColor]];

        NSLog(@"TKDetectorView, frame rect: %@", NSStringFromRect(frame));

    }
    return self;
}
- (void)awakeFromNib {

}

- (void)drawRect:(NSRect)dirtyRect {
    
    //NSBezierPath* temppath
    //CGWarpMouseCursorPosition(framerelative);
    [[NSColor whiteColor] setFill];
    NSRectFill(dirtyRect);
    //NSLog(@"drawrect called");
    NSRect r = NSMakeRect(10, 10, 10, 10);
    NSBezierPath *bp = [NSBezierPath bezierPathWithRect:r];
    NSColor *color = [NSColor whiteColor];
    [color set];
    [bp stroke];

    [self verbose];
    [self drawRegions];
    [self regionIntersections];
    [super drawRect:dirtyRect];
	//[NSBezierPath fillRect:self.frame];
    // Drawing code here.
}


-(void)verbose {
    if(visible) {
        //REMEMBER: fast enumeration over contents of an nsdictionary requires accessing its allKeys.
        for(NSTouch* x in [touch_identities allValues]) {
            //NSLog(@"yoyoyoyoyoyo we're operating with %@ at ", x);
            CGRect to_draw = CGRectMake(x.normalizedPosition.x*self.bounds.size.width, x.normalizedPosition.y*self.bounds.size.height, point_size, point_size);
            //NSLog(@"DRAWPOINT: %@", NSStringFromRect(to_draw));
            NSBezierPath* square = [NSBezierPath bezierPath];
            [square appendBezierPathWithRect:to_draw];
            [[NSColor whiteColor] setFill];
            [[NSColor blackColor] setStroke];
            [square stroke];

            [[NSString stringWithFormat:@"# = %lu\n dir = %.2lfº\n avg vel = %.2lf mm/s^2\n, inst. vel = %.2lf mm/s^2",
              [[touch_identities allValues] indexOfObject:x],
              [self direction:x],
              [self velocity:x],
             [self instantaneousVelocity:x]]
             drawInRect:to_draw withAttributes:font_attributes];
        }
    }
    [self setNeedsDisplay:YES];
    [super setNeedsDisplay:YES];
}


-(void)mouseEntered:(NSEvent *)theEvent {
    NSLog(@"Hello!");
}

//We need a touchesBegan event for taps.
-(void)touchesBeganWithEvent:(NSEvent *)event {
    touch_identities = [[NSMutableDictionary alloc] init];
    //NSLog(@"test");
    
    for(NSTouch* touch in [event touchesMatchingPhase:NSTouchPhaseAny inView:self]) {
        //NSLog(@"touch identity%@", [touch identity]);
        //[touch phys_record];
        [touch_identities setObject:touch forKey:[touch identity]];
        //NSLog(@"all touches: %@", touch_identities);
    }
    [self phys_record];
    [self setNeedsDisplay:YES];
    [super setNeedsDisplay:YES];
}

-(void)touchesMovedWithEvent:(NSEvent *)event {
    //NSLog(@"something else happened!");
    //NSLog(@"Touch detected %@", [event touchesMatchingPhase:NSTouchPhaseAny inView:self]);
    //touch_identities = [[NSMutableDictionary alloc] init];

    for(NSTouch* touch in [event touchesMatchingPhase:NSTouchPhaseAny inView:self]) {
       //NSLog(@"touch identity %@", [touch identity]);
        [touch_identities setObject:touch forKey:[touch identity]];
        //NSLog(@"all touches: %@", touch_identities);
    }
    //SUPER IMPORTANT THO
    [self phys_record];
    
    //JUST TO TEST
    for(NSTouch* touch in [event touchesMatchingPhase:NSTouchPhaseAny inView:self]) {
        //NSLog(@"delta test: %.16f",[self deltaX:touch]);
        [self velocity:touch];
    }
    [self setNeedsDisplay:YES];
    [super setNeedsDisplay:YES];
}

-(NSSet*)getTouches {
   //NSLog(@"Gettouches: %@", touches);
    return touches;
}
@end
