#import "startRadiansForPath.h"

typedef struct {
    CGPoint p0;
    CGPoint p1;
    CGPoint firstPointOfCurrentSubpath;
    CGPoint currentPoint;
    BOOL p0p1AreSet : 1;
} PathState;

static inline void updateStateWithMoveElement(PathState *state, CGPathElement const *element) {
    state->currentPoint = element->points[0];
    state->firstPointOfCurrentSubpath = state->currentPoint;
}

static inline void updateStateWithPoints(PathState *state, CGPoint p1, CGPoint currentPoint) {
    if (!state->p0p1AreSet) {
        state->p0 = state->currentPoint;
        state->p1 = p1;
        state->p0p1AreSet = YES;
    }
    state->currentPoint = currentPoint;
}

static inline void updateStateWithPointsElement(PathState *state, CGPathElement const *element, int newCurrentPointIndex) {
    updateStateWithPoints(state, element->points[0], element->points[newCurrentPointIndex]);
}

static void updateStateWithCloseElement(PathState *state, CGPathElement const *element) {
    updateStateWithPoints(state, state->firstPointOfCurrentSubpath, state->firstPointOfCurrentSubpath);
}

static void updateState(void *info, CGPathElement const *element) {
    PathState *state = info;
    switch (element->type) {
        case kCGPathElementMoveToPoint: return updateStateWithMoveElement(state, element);
        case kCGPathElementAddLineToPoint: return updateStateWithPointsElement(state, element, 0);
        case kCGPathElementAddQuadCurveToPoint: return updateStateWithPointsElement(state, element, 1);
        case kCGPathElementAddCurveToPoint: return updateStateWithPointsElement(state, element, 2);
        case kCGPathElementCloseSubpath: return updateStateWithCloseElement(state, element);
    }
}

CGFloat startRadiansForPath(UIBezierPath *path) {
    PathState state;
    memset(&state, 0, sizeof state);
    CGPathApply(path.CGPath, &state, updateState);
    return atan2f(state.p1.y - state.p0.y, state.p1.x - state.p0.x);
}
