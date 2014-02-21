function showRollTip(msg, e, s_bgcolor, s_width, s_justify) {
    if ( typeof RollTip == "undefined" || !RollTip.ready ) return;
    RollTip.reveal(msg, e, s_bgcolor, s_width, s_justify);
}

function hideRollTip() {
    if ( typeof RollTip == "undefined" || !RollTip.ready ) return;
    RollTip.conceal();
}
