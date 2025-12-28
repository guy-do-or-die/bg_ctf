// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./ISeason2Challenge9.sol";

contract SolverS2C9Variant {
    constructor(
        address target, 
        address minterAddress, 
        bytes memory sig1, // encode(str, this)
        bytes memory sig2, // packed(str, this)
        bytes memory sig3, // encode(this, str)
        bytes memory sig4  // packed(this, str)
    ) {
        // Try all 4 signatures
        bool success;
        
        try ISeason2Challenge9(target).unknown23cfec7e(minterAddress, sig1) { success = true; } catch {}
        if (!success) try ISeason2Challenge9(target).unknown23cfec7e(minterAddress, sig2) { success = true; } catch {}
        if (!success) try ISeason2Challenge9(target).unknown23cfec7e(minterAddress, sig3) { success = true; } catch {}
        if (!success) try ISeason2Challenge9(target).unknown23cfec7e(minterAddress, sig4) { success = true; } catch {}
        
        require(success, "All attempts failed");
    }
}
