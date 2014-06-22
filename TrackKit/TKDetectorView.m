//
//  TKDetectorView.m
//  TrackKit
//
//  Created by Kyle Reynolds on 5/15/14.
//  Copyright (c) 2014 Kyle Reynolds. All rights reserved.
//

#import "TKDetectorView.h"

@implementation TKDetectorView

- (id)initWithFrame:(NSRect)frame {

    self = [super initWithFrame:frame];
    if (self) {
        [self setNeedsDisplay:YES];
        [self setWantsLayer:YES];
        // Initialization code here.
        NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:[self visibleRect] options: NSTrackingMouseEnteredAndExited |NSTrackingInVisibleRect |NSTrackingActiveAlways owner:self userInfo:nil];
        [self addTrackingArea:trackingArea];
        touch_identities = [[NSMutableDictionary alloc] init];
        visible = true;

        [self setNeedsDisplay:YES];
        [super setNeedsDisplay:YES];
        [self setAcceptsTouchEvents:YES];
        [self setWantsRestingTouches:YES];
        [self becomeFirstResponder];
        
        NSLog(@" frame: %@", NSStringFromRect(self.frame));
    }
    return self;
}

- (void)awakeFromNib {
    NSLog(@"@im here");
	NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:[self visibleRect] options:NSTrackingMouseEnteredAndExited | NSTrackingInVisibleRect |NSTrackingActiveAlways owner:self userInfo:nil];
	
	[self addTrackingArea:trackingArea];
}

- (void)drawRect:(NSRect)dirtyRect {
    
    //NSBezierPath* temppath

    [[NSColor blueColor] setFill];
    NSRectFill(dirtyRect);
    NSLog(@"drawrect called");
    NSRect r = NSMakeRect(10, 10, 10, 10);
    NSBezierPath *bp = [NSBezierPath bezierPathWithRect:r];
    NSColor *color = [NSColor whiteColor];
    [color set];
    [bp stroke];

    [self verbose];
    [super drawRect:dirtyRect];
	//[NSBezierPath fillRect:self.frame];
    // Drawing code here.
}

-(void)verbose {
    NSLog(@"From the verbose log\n======");

    [[NSColor whiteColor] setFill];
    if(visible) {
        //REMEMBER: fast enumeration over an nsdictionary requires accessing its allKeys.
        for(NSTouch* x in [touch_identities allValues]) {
            NSLog(@"yoyoyoyoyoyo we're operating with %@ at ", x);
            CGRect to_draw = CGRectMake(x.normalizedPosition.x*self.bounds.size.width, x.normalizedPosition.y*self.bounds.size.height, (x.normalizedPosition.x*self.bounds.size.width)+10.0f, (x.normalizedPosition.y*self.bounds.size.height)+10.0f);
            NSLog(@"frame: %@", NSStringFromRect(self.frame));
            NSBezierPath* square = [NSBezierPath bezierPath];
            [square appendBezierPathWithRect:to_draw];
            [[NSColor whiteColor] setFill];
            [[NSColor whiteColor] setStroke];
            [square stroke];

           // CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
        }
        
    }
    [self setNeedsDisplay:YES];
    [super setNeedsDisplay:YES];
}


-(void)mouseEntered:(NSEvent *)theEvent {
    NSLog(@"Hello!");
}

-(void)touchesMovedWithEvent:(NSEvent *)event {
    NSLog(@"something else happened!");
    NSLog(@"Touch detected %@", [event touchesMatchingPhase:NSTouchPhaseAny inView:self]);
    touch_identities = [[NSMutableDictionary alloc] init];

    for(NSTouch* touch in [event touchesMatchingPhase:NSTouchPhaseAny inView:self]) {
        NSLog(@"touch identity %@", [touch identity]);
        [touch_identities setObject:touch forKey:[touch identity]];
        NSLog(@"all touches: %@", touch_identities);
    }
    //SUPER IMPORTANT THO
    [self setNeedsDisplay:YES];
    [super setNeedsDisplay:YES];
}

-(NSSet*)getTouches {
   //NSLog(@"Gettouches: %@", touches);
    return touches;
}

-(void)addRegion:(NSRect)userRegion {

}
@end
