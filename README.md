# SRv6 uSID Lab with IS-IS on Arista cEOS

A containerlab-based lab demonstrating **SRv6 Micro-Segment (uSID)** forwarding over an IS-IS backbone using Arista cEOS (EOS-4.36.0FX-SRV6).

## Topology

```
                       IS-IS Domain "ARUN"
                ┌──────── ─────────────────----─────┐
                │                                   │
  ┌────┐   Et1  │  ┌────┐  Et2&3  ┌────┐  Et4&5  ┌────┐  │  Et1  ┌────┐
  │ R1 ├────────┤  │ R2 ├─────────┤ R3 ├─────────┤ R4 ├──┤───────┤ R5 │
  └────┘        │  └────┘         └────┘         └────┘  │       └────┘
  Edge          │  uSID 1        uSID 2        uSID 3│       Edge
                └───────────────────────────-----─--─┘
```

- **R1** and **R5** are edge routers (static routes, no IS-IS/SRv6)
- **R2**, **R3**, **R4** form the SRv6 core with IS-IS Level-2 and SRv6 uSID
- R2-R3 and R3-R4 each have **dual parallel links**

## Addressing

| Router | Loopback0         | SRv6 uSID | IS-IS NET                 | Role |
|--------|-------------------|-----------|---------------------------|------|
| R1     | fc00:42:1111::/48 |    -      | -                         | Edge |
| R2     | fc00:42:1::/48    |    1      | 49.0001.1111.1111.1111.00 | Core |
| R3     | fc00:42:2::/48    |    2      | 49.0001.2222.2222.2222.00 | Core |
| R4     | fc00:42:3::/48    |    3      | 49.0001.4444.4444.4444.00 | Core |
| R5     | fc00:42:2222::/48 |    -      | -                         | Edge |

### Point-to-Point Links

| Link             |   Subnet          |
|------------------|-------------------|
| R1 Et1 -- R2 Et1 | 2001:db8:11::/126 |
| R2 Et2 -- R3 Et2 | 2001:db8:21::/126 |
| R2 Et3 -- R3 Et3 | 2001:db8:22::/126 |
| R3 Et4 -- R4 Et4 | 2001:db8:31::/126 |
| R3 Et5 -- R4 Et5 | 2001:db8:32::/126 |
| R4 Et1 -- R5 Et1 | 2001:db8:44::/126 |

## SRv6 Micro-Segment Configuration

All core routers share the same uSID block `fc00:42::/32`. Each router is assigned a unique 16-bit uSID within that block:

| Router | uSID Block   | End uSID | SID Address |
|--------|--------------|----------|-------------|
|   R2   | fc00:42::/32 | 1        | fc00:42:1:: |
|   R3   | fc00:42::/32 | 2        | fc00:42:2:: |
|   R4   | fc00:42::/32 | 3        | fc00:42:3:: |

The uSID architecture compresses a full SRv6 segment list into a single IPv6 destination address by packing multiple 16-bit micro-SIDs into the 128-bit address. For example, the segment list `[fc00:42:1::, fc00:42:2::, fc00:42:3::, fc00:42:2222::]` is compressed into:

```
fc00:42:1:2:3:2222::
```

## Verification

SRv6 ping from R1 to R5 (fc00:42:2222::) traversing R2 -> R3 -> R4 via explicit segment list:

```
R1# ping srv6 sid fc00:42:2222:: via segment-list fc00:42:1:: fc00:42:2:: fc00:42:3:: source Loopback0

Pinging fc00:42:1:2:3:2222:: [fc00:42:1:2:3:2222::] with 64 bytes
64 bytes from fc00:42:2222:: icmp_seq=1  ttl=61 time=3.375ms
64 bytes from fc00:42:2222:: icmp_seq=2  ttl=61 time=2.978ms
64 bytes from fc00:42:2222:: icmp_seq=3  ttl=61 time=2.925ms
```

## Prerequisites

- [Containerlab](https://containerlab.dev/) installed
- Arista cEOS-Lab image (`ceos:latest`) imported

## Usage

Deploy the lab:

```bash
./scripts/deploy.sh
```

Destroy the lab:

```bash
./scripts/destroy.sh
```

Access a router:

```bash
docker exec -it clab-isis-lab-R1 Cli
```

### Management Access

| Router | Management IP |
|--------|---------------|
| R1     | 172.20.20.11  |
| R2     | 172.20.20.12  |
| R3     | 172.20.20.13  |
| R4     | 172.20.20.14  |
| R5     | 172.20.20.15  |

## Project Structure

```
.
├── topo.yml              # Containerlab topology definition
├── configs/
│   ├── R1.cfg            # Edge router (static routing)
│   ├── R2.cfg            # IS-IS + SRv6 uSID 1
│   ├── R3.cfg            # IS-IS + SRv6 uSID 2
│   ├── R4.cfg            # IS-IS + SRv6 uSID 3
│   └── R5.cfg            # Edge router (static routing)
└── scripts/
    ├── deploy.sh         # Deploy the lab
    └── destroy.sh        # Destroy and cleanup
```

