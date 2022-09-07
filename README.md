# autotickrate

This sourcemod plugin enables changing the tick rate when the number of clients crosses a threshold.

## Configuration

### Convars

**sm_autotickrate_enable**: 0 to disable, 1 to enable (default 0)

**sm_autotickrate_numclients**: maximum number of clients for high tickrate; when passed, low rate will be used on next load (default 30)

**sm_autotickrate_hightick**: default tick rate (default 128)

**sm_autotickrate_lowtick**: tick rate under high load (default 64)

## Notes

Tick rate will be set on next map load whenever the client count breaches the threshold during a map.

A temporary file is created to flag that the "low" tickrate should be used; it will be deleted after
application.
