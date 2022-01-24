; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=amdgcn-mesa-mesa3d -mcpu=gfx900 < %s | FileCheck -check-prefixes=GCN,GFX9 %s
; RUN: llc -mtriple=amdgcn-mesa-mesa3d -mcpu=gfx1010 -mattr=+wavefrontsize64 < %s | FileCheck -check-prefixes=GCN,GFX10 %s

; Test using saddr addressing mode of global_*store_* flat instructions.

define amdgpu_ps void @global_store_saddr_i8_zext_vgpr(i8 addrspace(1)* inreg %sbase, i32 addrspace(1)* %voffset.ptr, i8 %data) {
; GCN-LABEL: global_store_saddr_i8_zext_vgpr:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_load_dword v0, v[0:1], off
; GCN-NEXT:    s_waitcnt vmcnt(0)
; GCN-NEXT:    global_store_byte v0, v2, s[2:3]
; GCN-NEXT:    s_endpgm
  %voffset = load i32, i32 addrspace(1)* %voffset.ptr
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  store i8 %data, i8 addrspace(1)* %gep0
  ret void
}

; Maximum positive offset on gfx10
define amdgpu_ps void @global_store_saddr_i8_zext_vgpr_offset_2047(i8 addrspace(1)* inreg %sbase, i32 addrspace(1)* %voffset.ptr, i8 %data) {
; GCN-LABEL: global_store_saddr_i8_zext_vgpr_offset_2047:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_load_dword v0, v[0:1], off
; GCN-NEXT:    s_waitcnt vmcnt(0)
; GCN-NEXT:    global_store_byte v0, v2, s[2:3] offset:2047
; GCN-NEXT:    s_endpgm
  %voffset = load i32, i32 addrspace(1)* %voffset.ptr
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep1 = getelementptr inbounds i8, i8 addrspace(1)* %gep0, i64 2047
  store i8 %data, i8 addrspace(1)* %gep1
  ret void
}

; Maximum negative offset on gfx10
define amdgpu_ps void @global_store_saddr_i8_zext_vgpr_offset_neg2048(i8 addrspace(1)* inreg %sbase, i32 addrspace(1)* %voffset.ptr, i8 %data) {
; GCN-LABEL: global_store_saddr_i8_zext_vgpr_offset_neg2048:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_load_dword v0, v[0:1], off
; GCN-NEXT:    s_waitcnt vmcnt(0)
; GCN-NEXT:    global_store_byte v0, v2, s[2:3] offset:-2048
; GCN-NEXT:    s_endpgm
  %voffset = load i32, i32 addrspace(1)* %voffset.ptr
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep1 = getelementptr inbounds i8, i8 addrspace(1)* %gep0, i64 -2048
  store i8 %data, i8 addrspace(1)* %gep1
  ret void
}

; --------------------------------------------------------------------------------
; Uniformity edge cases
; --------------------------------------------------------------------------------

@ptr.in.lds = internal addrspace(3) global i8 addrspace(1)* undef

; Base pointer is uniform, but also in VGPRs
define amdgpu_ps void @global_store_saddr_uniform_ptr_in_vgprs(i32 %voffset, i8 %data) {
; GCN-LABEL: global_store_saddr_uniform_ptr_in_vgprs:
; GCN:       ; %bb.0:
; GCN-NEXT:    v_mov_b32_e32 v2, 0
; GCN-NEXT:    ds_read_b64 v[2:3], v2
; GCN-NEXT:    s_waitcnt lgkmcnt(0)
; GCN-NEXT:    v_readfirstlane_b32 s0, v2
; GCN-NEXT:    v_readfirstlane_b32 s1, v3
; GCN-NEXT:    s_nop 4
; GCN-NEXT:    global_store_byte v0, v1, s[0:1]
; GCN-NEXT:    s_endpgm
  %sbase = load i8 addrspace(1)*, i8 addrspace(1)* addrspace(3)* @ptr.in.lds
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  store i8 %data, i8 addrspace(1)* %gep0
  ret void
}

; Base pointer is uniform, but also in VGPRs, with imm offset
define amdgpu_ps void @global_store_saddr_uniform_ptr_in_vgprs_immoffset(i32 %voffset, i8 %data) {
; GCN-LABEL: global_store_saddr_uniform_ptr_in_vgprs_immoffset:
; GCN:       ; %bb.0:
; GCN-NEXT:    v_mov_b32_e32 v2, 0
; GCN-NEXT:    ds_read_b64 v[2:3], v2
; GCN-NEXT:    s_waitcnt lgkmcnt(0)
; GCN-NEXT:    v_readfirstlane_b32 s0, v2
; GCN-NEXT:    v_readfirstlane_b32 s1, v3
; GCN-NEXT:    s_nop 4
; GCN-NEXT:    global_store_byte v0, v1, s[0:1] offset:-120
; GCN-NEXT:    s_endpgm
  %sbase = load i8 addrspace(1)*, i8 addrspace(1)* addrspace(3)* @ptr.in.lds
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep1 = getelementptr inbounds i8, i8 addrspace(1)* %gep0, i64 -120
  store i8 %data, i8 addrspace(1)* %gep1
  ret void
}

; --------------------------------------------------------------------------------
; Stress various type stores
; --------------------------------------------------------------------------------

define amdgpu_ps void @global_store_saddr_i16_zext_vgpr(i8 addrspace(1)* inreg %sbase, i32 %voffset, i16 %data) {
; GCN-LABEL: global_store_saddr_i16_zext_vgpr:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_short v0, v1, s[2:3]
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep0.cast = bitcast i8 addrspace(1)* %gep0 to i16 addrspace(1)*
  store i16 %data, i16 addrspace(1)* %gep0.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_i16_zext_vgpr_offset_neg128(i8 addrspace(1)* inreg %sbase, i32 %voffset, i16 %data) {
; GCN-LABEL: global_store_saddr_i16_zext_vgpr_offset_neg128:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_short v0, v1, s[2:3] offset:-128
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep1 = getelementptr inbounds i8, i8 addrspace(1)* %gep0, i64 -128
  %gep1.cast = bitcast i8 addrspace(1)* %gep1 to i16 addrspace(1)*
  store i16 %data, i16 addrspace(1)* %gep1.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_f16_zext_vgpr(i8 addrspace(1)* inreg %sbase, i32 %voffset, half %data) {
; GCN-LABEL: global_store_saddr_f16_zext_vgpr:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_short v0, v1, s[2:3]
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep0.cast = bitcast i8 addrspace(1)* %gep0 to half addrspace(1)*
  store half %data, half addrspace(1)* %gep0.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_f16_zext_vgpr_offset_neg128(i8 addrspace(1)* inreg %sbase, i32 %voffset, half %data) {
; GCN-LABEL: global_store_saddr_f16_zext_vgpr_offset_neg128:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_short v0, v1, s[2:3] offset:-128
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep1 = getelementptr inbounds i8, i8 addrspace(1)* %gep0, i64 -128
  %gep1.cast = bitcast i8 addrspace(1)* %gep1 to half addrspace(1)*
  store half %data, half addrspace(1)* %gep1.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_i32_zext_vgpr(i8 addrspace(1)* inreg %sbase, i32 %voffset, i32 %data) {
; GCN-LABEL: global_store_saddr_i32_zext_vgpr:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dword v0, v1, s[2:3]
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep0.cast = bitcast i8 addrspace(1)* %gep0 to i32 addrspace(1)*
  store i32 %data, i32 addrspace(1)* %gep0.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_i32_zext_vgpr_offset_neg128(i8 addrspace(1)* inreg %sbase, i32 %voffset, i32 %data) {
; GCN-LABEL: global_store_saddr_i32_zext_vgpr_offset_neg128:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dword v0, v1, s[2:3] offset:-128
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep1 = getelementptr inbounds i8, i8 addrspace(1)* %gep0, i64 -128
  %gep1.cast = bitcast i8 addrspace(1)* %gep1 to i32 addrspace(1)*
  store i32 %data, i32 addrspace(1)* %gep1.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_f32_zext_vgpr(i8 addrspace(1)* inreg %sbase, i32 %voffset, float %data) {
; GCN-LABEL: global_store_saddr_f32_zext_vgpr:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dword v0, v1, s[2:3]
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep0.cast = bitcast i8 addrspace(1)* %gep0 to float addrspace(1)*
  store float %data, float addrspace(1)* %gep0.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_f32_zext_vgpr_offset_neg128(i8 addrspace(1)* inreg %sbase, i32 %voffset, float %data) {
; GCN-LABEL: global_store_saddr_f32_zext_vgpr_offset_neg128:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dword v0, v1, s[2:3] offset:-128
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep1 = getelementptr inbounds i8, i8 addrspace(1)* %gep0, i64 -128
  %gep1.cast = bitcast i8 addrspace(1)* %gep1 to float addrspace(1)*
  store float %data, float addrspace(1)* %gep1.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_p3_zext_vgpr(i8 addrspace(1)* inreg %sbase, i32 %voffset, i8 addrspace(3)* %data) {
; GCN-LABEL: global_store_saddr_p3_zext_vgpr:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dword v0, v1, s[2:3]
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep0.cast = bitcast i8 addrspace(1)* %gep0 to i8 addrspace(3)* addrspace(1)*
  store i8 addrspace(3)* %data, i8 addrspace(3)* addrspace(1)* %gep0.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_p3_zext_vgpr_offset_neg128(i8 addrspace(1)* inreg %sbase, i32 %voffset, i8 addrspace(3)* %data) {
; GCN-LABEL: global_store_saddr_p3_zext_vgpr_offset_neg128:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dword v0, v1, s[2:3] offset:-128
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep1 = getelementptr inbounds i8, i8 addrspace(1)* %gep0, i64 -128
  %gep1.cast = bitcast i8 addrspace(1)* %gep1 to i8 addrspace(3)* addrspace(1)*
  store i8 addrspace(3)* %data, i8 addrspace(3)* addrspace(1)* %gep1.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_i64_zext_vgpr(i8 addrspace(1)* inreg %sbase, i32 %voffset, i64 %data) {
; GCN-LABEL: global_store_saddr_i64_zext_vgpr:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx2 v0, v[1:2], s[2:3]
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep0.cast = bitcast i8 addrspace(1)* %gep0 to i64 addrspace(1)*
  store i64 %data, i64 addrspace(1)* %gep0.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_i64_zext_vgpr_offset_neg128(i8 addrspace(1)* inreg %sbase, i32 %voffset, i64 %data) {
; GCN-LABEL: global_store_saddr_i64_zext_vgpr_offset_neg128:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx2 v0, v[1:2], s[2:3] offset:-128
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep1 = getelementptr inbounds i8, i8 addrspace(1)* %gep0, i64 -128
  %gep1.cast = bitcast i8 addrspace(1)* %gep1 to i64 addrspace(1)*
  store i64 %data, i64 addrspace(1)* %gep1.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_f64_zext_vgpr(i8 addrspace(1)* inreg %sbase, i32 %voffset, double %data) {
; GCN-LABEL: global_store_saddr_f64_zext_vgpr:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx2 v0, v[1:2], s[2:3]
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep0.cast = bitcast i8 addrspace(1)* %gep0 to double addrspace(1)*
  store double %data, double addrspace(1)* %gep0.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_f64_zext_vgpr_offset_neg128(i8 addrspace(1)* inreg %sbase, i32 %voffset, double %data) {
; GCN-LABEL: global_store_saddr_f64_zext_vgpr_offset_neg128:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx2 v0, v[1:2], s[2:3] offset:-128
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep1 = getelementptr inbounds i8, i8 addrspace(1)* %gep0, i64 -128
  %gep1.cast = bitcast i8 addrspace(1)* %gep1 to double addrspace(1)*
  store double %data, double addrspace(1)* %gep1.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_v2i32_zext_vgpr(i8 addrspace(1)* inreg %sbase, i32 %voffset, <2 x i32> %data) {
; GCN-LABEL: global_store_saddr_v2i32_zext_vgpr:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx2 v0, v[1:2], s[2:3]
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep0.cast = bitcast i8 addrspace(1)* %gep0 to <2 x i32> addrspace(1)*
  store <2 x i32> %data, <2 x i32> addrspace(1)* %gep0.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_v2i32_zext_vgpr_offset_neg128(i8 addrspace(1)* inreg %sbase, i32 %voffset, <2 x i32> %data) {
; GCN-LABEL: global_store_saddr_v2i32_zext_vgpr_offset_neg128:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx2 v0, v[1:2], s[2:3] offset:-128
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep1 = getelementptr inbounds i8, i8 addrspace(1)* %gep0, i64 -128
  %gep1.cast = bitcast i8 addrspace(1)* %gep1 to <2 x i32> addrspace(1)*
  store <2 x i32> %data, <2 x i32> addrspace(1)* %gep1.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_v2f32_zext_vgpr(i8 addrspace(1)* inreg %sbase, i32 %voffset, <2 x float> %data) {
; GCN-LABEL: global_store_saddr_v2f32_zext_vgpr:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx2 v0, v[1:2], s[2:3]
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep0.cast = bitcast i8 addrspace(1)* %gep0 to <2 x float> addrspace(1)*
  store <2 x float> %data, <2 x float> addrspace(1)* %gep0.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_v2f32_zext_vgpr_offset_neg128(i8 addrspace(1)* inreg %sbase, i32 %voffset, <2 x float> %data) {
; GCN-LABEL: global_store_saddr_v2f32_zext_vgpr_offset_neg128:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx2 v0, v[1:2], s[2:3] offset:-128
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep1 = getelementptr inbounds i8, i8 addrspace(1)* %gep0, i64 -128
  %gep1.cast = bitcast i8 addrspace(1)* %gep1 to <2 x float> addrspace(1)*
  store <2 x float> %data, <2 x float> addrspace(1)* %gep1.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_v4i16_zext_vgpr(i8 addrspace(1)* inreg %sbase, i32 %voffset, <4 x i16> %data) {
; GCN-LABEL: global_store_saddr_v4i16_zext_vgpr:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx2 v0, v[1:2], s[2:3]
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep0.cast = bitcast i8 addrspace(1)* %gep0 to <4 x i16> addrspace(1)*
  store <4 x i16> %data, <4 x i16> addrspace(1)* %gep0.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_v4i16_zext_vgpr_offset_neg128(i8 addrspace(1)* inreg %sbase, i32 %voffset, <4 x i16> %data) {
; GCN-LABEL: global_store_saddr_v4i16_zext_vgpr_offset_neg128:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx2 v0, v[1:2], s[2:3] offset:-128
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep1 = getelementptr inbounds i8, i8 addrspace(1)* %gep0, i64 -128
  %gep1.cast = bitcast i8 addrspace(1)* %gep1 to <4 x i16> addrspace(1)*
  store <4 x i16> %data, <4 x i16> addrspace(1)* %gep1.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_v4f16_zext_vgpr(i8 addrspace(1)* inreg %sbase, i32 %voffset, <4 x half> %data) {
; GCN-LABEL: global_store_saddr_v4f16_zext_vgpr:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx2 v0, v[1:2], s[2:3]
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep0.cast = bitcast i8 addrspace(1)* %gep0 to <4 x half> addrspace(1)*
  store <4 x half> %data, <4 x half> addrspace(1)* %gep0.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_v4f16_zext_vgpr_offset_neg128(i8 addrspace(1)* inreg %sbase, i32 %voffset, <4 x half> %data) {
; GCN-LABEL: global_store_saddr_v4f16_zext_vgpr_offset_neg128:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx2 v0, v[1:2], s[2:3] offset:-128
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep1 = getelementptr inbounds i8, i8 addrspace(1)* %gep0, i64 -128
  %gep1.cast = bitcast i8 addrspace(1)* %gep1 to <4 x half> addrspace(1)*
  store <4 x half> %data, <4 x half> addrspace(1)* %gep1.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_p1_zext_vgpr(i8 addrspace(1)* inreg %sbase, i32 %voffset, i8 addrspace(1)* %data) {
; GCN-LABEL: global_store_saddr_p1_zext_vgpr:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx2 v0, v[1:2], s[2:3]
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep0.cast = bitcast i8 addrspace(1)* %gep0 to i8 addrspace(1)* addrspace(1)*
  store i8 addrspace(1)* %data, i8 addrspace(1)* addrspace(1)* %gep0.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_p1_zext_vgpr_offset_neg128(i8 addrspace(1)* inreg %sbase, i32 %voffset, i8 addrspace(1)* %data) {
; GCN-LABEL: global_store_saddr_p1_zext_vgpr_offset_neg128:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx2 v0, v[1:2], s[2:3] offset:-128
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep1 = getelementptr inbounds i8, i8 addrspace(1)* %gep0, i64 -128
  %gep1.cast = bitcast i8 addrspace(1)* %gep1 to i8 addrspace(1)* addrspace(1)*
  store i8 addrspace(1)* %data, i8 addrspace(1)* addrspace(1)* %gep1.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_v3i32_zext_vgpr(i8 addrspace(1)* inreg %sbase, i32 %voffset, <3 x i32> %data) {
; GCN-LABEL: global_store_saddr_v3i32_zext_vgpr:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx3 v0, v[1:3], s[2:3]
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep0.cast = bitcast i8 addrspace(1)* %gep0 to <3 x i32> addrspace(1)*
  store <3 x i32> %data, <3 x i32> addrspace(1)* %gep0.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_v3i32_zext_vgpr_offset_neg128(i8 addrspace(1)* inreg %sbase, i32 %voffset, <3 x i32> %data) {
; GCN-LABEL: global_store_saddr_v3i32_zext_vgpr_offset_neg128:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx3 v0, v[1:3], s[2:3] offset:-128
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep1 = getelementptr inbounds i8, i8 addrspace(1)* %gep0, i64 -128
  %gep1.cast = bitcast i8 addrspace(1)* %gep1 to <3 x i32> addrspace(1)*
  store <3 x i32> %data, <3 x i32> addrspace(1)* %gep1.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_v3f32_zext_vgpr(i8 addrspace(1)* inreg %sbase, i32 %voffset, <3 x float> %data) {
; GCN-LABEL: global_store_saddr_v3f32_zext_vgpr:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx3 v0, v[1:3], s[2:3]
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep0.cast = bitcast i8 addrspace(1)* %gep0 to <3 x float> addrspace(1)*
  store <3 x float> %data, <3 x float> addrspace(1)* %gep0.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_v3f32_zext_vgpr_offset_neg128(i8 addrspace(1)* inreg %sbase, i32 %voffset, <3 x float> %data) {
; GCN-LABEL: global_store_saddr_v3f32_zext_vgpr_offset_neg128:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx3 v0, v[1:3], s[2:3] offset:-128
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep1 = getelementptr inbounds i8, i8 addrspace(1)* %gep0, i64 -128
  %gep1.cast = bitcast i8 addrspace(1)* %gep1 to <3 x float> addrspace(1)*
  store <3 x float> %data, <3 x float> addrspace(1)* %gep1.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_v6i16_zext_vgpr(i8 addrspace(1)* inreg %sbase, i32 %voffset, <6 x i16> %data) {
; GCN-LABEL: global_store_saddr_v6i16_zext_vgpr:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx3 v0, v[1:3], s[2:3]
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep0.cast = bitcast i8 addrspace(1)* %gep0 to <6 x i16> addrspace(1)*
  store <6 x i16> %data, <6 x i16> addrspace(1)* %gep0.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_v6i16_zext_vgpr_offset_neg128(i8 addrspace(1)* inreg %sbase, i32 %voffset, <6 x i16> %data) {
; GCN-LABEL: global_store_saddr_v6i16_zext_vgpr_offset_neg128:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx3 v0, v[1:3], s[2:3] offset:-128
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep1 = getelementptr inbounds i8, i8 addrspace(1)* %gep0, i64 -128
  %gep1.cast = bitcast i8 addrspace(1)* %gep1 to <6 x i16> addrspace(1)*
  store <6 x i16> %data, <6 x i16> addrspace(1)* %gep1.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_v6f16_zext_vgpr(i8 addrspace(1)* inreg %sbase, i32 %voffset, <6 x half> %data) {
; GCN-LABEL: global_store_saddr_v6f16_zext_vgpr:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx3 v0, v[1:3], s[2:3]
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep0.cast = bitcast i8 addrspace(1)* %gep0 to <6 x half> addrspace(1)*
  store <6 x half> %data, <6 x half> addrspace(1)* %gep0.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_v6f16_zext_vgpr_offset_neg128(i8 addrspace(1)* inreg %sbase, i32 %voffset, <6 x half> %data) {
; GCN-LABEL: global_store_saddr_v6f16_zext_vgpr_offset_neg128:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx3 v0, v[1:3], s[2:3] offset:-128
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep1 = getelementptr inbounds i8, i8 addrspace(1)* %gep0, i64 -128
  %gep1.cast = bitcast i8 addrspace(1)* %gep1 to <6 x half> addrspace(1)*
  store <6 x half> %data, <6 x half> addrspace(1)* %gep1.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_v4i32_zext_vgpr(i8 addrspace(1)* inreg %sbase, i32 %voffset, <4 x i32> %data) {
; GCN-LABEL: global_store_saddr_v4i32_zext_vgpr:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx4 v0, v[1:4], s[2:3]
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep0.cast = bitcast i8 addrspace(1)* %gep0 to <4 x i32> addrspace(1)*
  store <4 x i32> %data, <4 x i32> addrspace(1)* %gep0.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_v4i32_zext_vgpr_offset_neg128(i8 addrspace(1)* inreg %sbase, i32 %voffset, <4 x i32> %data) {
; GCN-LABEL: global_store_saddr_v4i32_zext_vgpr_offset_neg128:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx4 v0, v[1:4], s[2:3] offset:-128
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep1 = getelementptr inbounds i8, i8 addrspace(1)* %gep0, i64 -128
  %gep1.cast = bitcast i8 addrspace(1)* %gep1 to <4 x i32> addrspace(1)*
  store <4 x i32> %data, <4 x i32> addrspace(1)* %gep1.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_v4f32_zext_vgpr(i8 addrspace(1)* inreg %sbase, i32 %voffset, <4 x float> %data) {
; GCN-LABEL: global_store_saddr_v4f32_zext_vgpr:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx4 v0, v[1:4], s[2:3]
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep0.cast = bitcast i8 addrspace(1)* %gep0 to <4 x float> addrspace(1)*
  store <4 x float> %data, <4 x float> addrspace(1)* %gep0.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_v4f32_zext_vgpr_offset_neg128(i8 addrspace(1)* inreg %sbase, i32 %voffset, <4 x float> %data) {
; GCN-LABEL: global_store_saddr_v4f32_zext_vgpr_offset_neg128:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx4 v0, v[1:4], s[2:3] offset:-128
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep1 = getelementptr inbounds i8, i8 addrspace(1)* %gep0, i64 -128
  %gep1.cast = bitcast i8 addrspace(1)* %gep1 to <4 x float> addrspace(1)*
  store <4 x float> %data, <4 x float> addrspace(1)* %gep1.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_v2i64_zext_vgpr(i8 addrspace(1)* inreg %sbase, i32 %voffset, <2 x i64> %data) {
; GCN-LABEL: global_store_saddr_v2i64_zext_vgpr:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx4 v0, v[1:4], s[2:3]
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep0.cast = bitcast i8 addrspace(1)* %gep0 to <2 x i64> addrspace(1)*
  store <2 x i64> %data, <2 x i64> addrspace(1)* %gep0.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_v2i64_zext_vgpr_offset_neg128(i8 addrspace(1)* inreg %sbase, i32 %voffset, <2 x i64> %data) {
; GCN-LABEL: global_store_saddr_v2i64_zext_vgpr_offset_neg128:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx4 v0, v[1:4], s[2:3] offset:-128
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep1 = getelementptr inbounds i8, i8 addrspace(1)* %gep0, i64 -128
  %gep1.cast = bitcast i8 addrspace(1)* %gep1 to <2 x i64> addrspace(1)*
  store <2 x i64> %data, <2 x i64> addrspace(1)* %gep1.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_v2f64_zext_vgpr(i8 addrspace(1)* inreg %sbase, i32 %voffset, <2 x double> %data) {
; GCN-LABEL: global_store_saddr_v2f64_zext_vgpr:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx4 v0, v[1:4], s[2:3]
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep0.cast = bitcast i8 addrspace(1)* %gep0 to <2 x double> addrspace(1)*
  store <2 x double> %data, <2 x double> addrspace(1)* %gep0.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_v2f64_zext_vgpr_offset_neg128(i8 addrspace(1)* inreg %sbase, i32 %voffset, <2 x double> %data) {
; GCN-LABEL: global_store_saddr_v2f64_zext_vgpr_offset_neg128:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx4 v0, v[1:4], s[2:3] offset:-128
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep1 = getelementptr inbounds i8, i8 addrspace(1)* %gep0, i64 -128
  %gep1.cast = bitcast i8 addrspace(1)* %gep1 to <2 x double> addrspace(1)*
  store <2 x double> %data, <2 x double> addrspace(1)* %gep1.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_v8i16_zext_vgpr(i8 addrspace(1)* inreg %sbase, i32 %voffset, <8 x i16> %data) {
; GCN-LABEL: global_store_saddr_v8i16_zext_vgpr:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx4 v0, v[1:4], s[2:3]
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep0.cast = bitcast i8 addrspace(1)* %gep0 to <8 x i16> addrspace(1)*
  store <8 x i16> %data, <8 x i16> addrspace(1)* %gep0.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_v8i16_zext_vgpr_offset_neg128(i8 addrspace(1)* inreg %sbase, i32 %voffset, <8 x i16> %data) {
; GCN-LABEL: global_store_saddr_v8i16_zext_vgpr_offset_neg128:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx4 v0, v[1:4], s[2:3] offset:-128
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep1 = getelementptr inbounds i8, i8 addrspace(1)* %gep0, i64 -128
  %gep1.cast = bitcast i8 addrspace(1)* %gep1 to <8 x i16> addrspace(1)*
  store <8 x i16> %data, <8 x i16> addrspace(1)* %gep1.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_v8f16_zext_vgpr(i8 addrspace(1)* inreg %sbase, i32 %voffset, <8 x half> %data) {
; GCN-LABEL: global_store_saddr_v8f16_zext_vgpr:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx4 v0, v[1:4], s[2:3]
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep0.cast = bitcast i8 addrspace(1)* %gep0 to <8 x half> addrspace(1)*
  store <8 x half> %data, <8 x half> addrspace(1)* %gep0.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_v8f16_zext_vgpr_offset_neg128(i8 addrspace(1)* inreg %sbase, i32 %voffset, <8 x half> %data) {
; GCN-LABEL: global_store_saddr_v8f16_zext_vgpr_offset_neg128:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx4 v0, v[1:4], s[2:3] offset:-128
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep1 = getelementptr inbounds i8, i8 addrspace(1)* %gep0, i64 -128
  %gep1.cast = bitcast i8 addrspace(1)* %gep1 to <8 x half> addrspace(1)*
  store <8 x half> %data, <8 x half> addrspace(1)* %gep1.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_v2p1_zext_vgpr(i8 addrspace(1)* inreg %sbase, i32 %voffset, <2 x i8 addrspace(1)*> %data) {
; GCN-LABEL: global_store_saddr_v2p1_zext_vgpr:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx4 v0, v[1:4], s[2:3]
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep0.cast = bitcast i8 addrspace(1)* %gep0 to <2 x i8 addrspace(1)*> addrspace(1)*
  store <2 x i8 addrspace(1)*> %data, <2 x i8 addrspace(1)*> addrspace(1)* %gep0.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_v2p1_zext_vgpr_offset_neg128(i8 addrspace(1)* inreg %sbase, i32 %voffset, <2 x i8 addrspace(1)*> %data) {
; GCN-LABEL: global_store_saddr_v2p1_zext_vgpr_offset_neg128:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx4 v0, v[1:4], s[2:3] offset:-128
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep1 = getelementptr inbounds i8, i8 addrspace(1)* %gep0, i64 -128
  %gep1.cast = bitcast i8 addrspace(1)* %gep1 to <2 x i8 addrspace(1)*> addrspace(1)*
  store <2 x i8 addrspace(1)*> %data, <2 x i8 addrspace(1)*> addrspace(1)* %gep1.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_v4p3_zext_vgpr(i8 addrspace(1)* inreg %sbase, i32 %voffset, <4 x i8 addrspace(3)*> %data) {
; GCN-LABEL: global_store_saddr_v4p3_zext_vgpr:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx4 v0, v[1:4], s[2:3]
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep0.cast = bitcast i8 addrspace(1)* %gep0 to <4 x i8 addrspace(3)*> addrspace(1)*
  store <4 x i8 addrspace(3)*> %data, <4 x i8 addrspace(3)*> addrspace(1)* %gep0.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_v4p3_zext_vgpr_offset_neg128(i8 addrspace(1)* inreg %sbase, i32 %voffset, <4 x i8 addrspace(3)*> %data) {
; GCN-LABEL: global_store_saddr_v4p3_zext_vgpr_offset_neg128:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_dwordx4 v0, v[1:4], s[2:3] offset:-128
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep1 = getelementptr inbounds i8, i8 addrspace(1)* %gep0, i64 -128
  %gep1.cast = bitcast i8 addrspace(1)* %gep1 to <4 x i8 addrspace(3)*> addrspace(1)*
  store <4 x i8 addrspace(3)*> %data, <4 x i8 addrspace(3)*> addrspace(1)* %gep1.cast
  ret void
}

; --------------------------------------------------------------------------------
; Atomic store
; --------------------------------------------------------------------------------

define amdgpu_ps void @atomic_global_store_saddr_i32_zext_vgpr(i8 addrspace(1)* inreg %sbase, i32 %voffset, i32 %data) {
; GFX9-LABEL: atomic_global_store_saddr_i32_zext_vgpr:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_store_dword v0, v1, s[2:3]
; GFX9-NEXT:    s_endpgm
;
; GFX10-LABEL: atomic_global_store_saddr_i32_zext_vgpr:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    s_waitcnt vmcnt(0) lgkmcnt(0)
; GFX10-NEXT:    s_waitcnt_vscnt null, 0x0
; GFX10-NEXT:    global_store_dword v0, v1, s[2:3]
; GFX10-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep0.cast = bitcast i8 addrspace(1)* %gep0 to i32 addrspace(1)*
  store atomic i32 %data, i32 addrspace(1)* %gep0.cast seq_cst, align 4
  ret void
}

define amdgpu_ps void @atomic_global_store_saddr_i32_zext_vgpr_offset_neg128(i8 addrspace(1)* inreg %sbase, i32 %voffset, i32 %data) {
; GFX9-LABEL: atomic_global_store_saddr_i32_zext_vgpr_offset_neg128:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_store_dword v0, v1, s[2:3] offset:-128
; GFX9-NEXT:    s_endpgm
;
; GFX10-LABEL: atomic_global_store_saddr_i32_zext_vgpr_offset_neg128:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    s_waitcnt vmcnt(0) lgkmcnt(0)
; GFX10-NEXT:    s_waitcnt_vscnt null, 0x0
; GFX10-NEXT:    global_store_dword v0, v1, s[2:3] offset:-128
; GFX10-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep1 = getelementptr inbounds i8, i8 addrspace(1)* %gep0, i64 -128
  %gep1.cast = bitcast i8 addrspace(1)* %gep1 to i32 addrspace(1)*
  store atomic i32 %data, i32 addrspace(1)* %gep1.cast seq_cst, align 4
  ret void
}

define amdgpu_ps void @atomic_global_store_saddr_i64_zext_vgpr(i8 addrspace(1)* inreg %sbase, i32 %voffset, i64 %data) {
; GFX9-LABEL: atomic_global_store_saddr_i64_zext_vgpr:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_store_dwordx2 v0, v[1:2], s[2:3]
; GFX9-NEXT:    s_endpgm
;
; GFX10-LABEL: atomic_global_store_saddr_i64_zext_vgpr:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    s_waitcnt vmcnt(0) lgkmcnt(0)
; GFX10-NEXT:    s_waitcnt_vscnt null, 0x0
; GFX10-NEXT:    global_store_dwordx2 v0, v[1:2], s[2:3]
; GFX10-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep0.cast = bitcast i8 addrspace(1)* %gep0 to i64 addrspace(1)*
  store atomic i64 %data, i64 addrspace(1)* %gep0.cast seq_cst, align 8
  ret void
}

define amdgpu_ps void @atomic_global_store_saddr_i64_zext_vgpr_offset_neg128(i8 addrspace(1)* inreg %sbase, i32 %voffset, i64 %data) {
; GFX9-LABEL: atomic_global_store_saddr_i64_zext_vgpr_offset_neg128:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_store_dwordx2 v0, v[1:2], s[2:3] offset:-128
; GFX9-NEXT:    s_endpgm
;
; GFX10-LABEL: atomic_global_store_saddr_i64_zext_vgpr_offset_neg128:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    s_waitcnt vmcnt(0) lgkmcnt(0)
; GFX10-NEXT:    s_waitcnt_vscnt null, 0x0
; GFX10-NEXT:    global_store_dwordx2 v0, v[1:2], s[2:3] offset:-128
; GFX10-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep1 = getelementptr inbounds i8, i8 addrspace(1)* %gep0, i64 -128
  %gep1.cast = bitcast i8 addrspace(1)* %gep1 to i64 addrspace(1)*
  store atomic i64 %data, i64 addrspace(1)* %gep1.cast seq_cst, align 8
  ret void
}

; --------------------------------------------------------------------------------
; D16 HI store (hi 16)
; --------------------------------------------------------------------------------

define amdgpu_ps void @global_store_saddr_i16_d16hi_zext_vgpr(i8 addrspace(1)* inreg %sbase, i32 %voffset, <2 x i16> %data) {
; GCN-LABEL: global_store_saddr_i16_d16hi_zext_vgpr:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_short_d16_hi v0, v1, s[2:3]
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep0.cast = bitcast i8 addrspace(1)* %gep0 to i16 addrspace(1)*
  %data.hi = extractelement <2 x i16> %data, i32 1
  store i16 %data.hi, i16 addrspace(1)* %gep0.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_i16_d16hi_zext_vgpr_offset_neg128(i8 addrspace(1)* inreg %sbase, i32 %voffset, <2 x i16> %data) {
; GCN-LABEL: global_store_saddr_i16_d16hi_zext_vgpr_offset_neg128:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_short_d16_hi v0, v1, s[2:3] offset:-128
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep1 = getelementptr inbounds i8, i8 addrspace(1)* %gep0, i64 -128
  %gep1.cast = bitcast i8 addrspace(1)* %gep1 to i16 addrspace(1)*
  %data.hi = extractelement <2 x i16> %data, i32 1
  store i16 %data.hi, i16 addrspace(1)* %gep1.cast
  ret void
}

define amdgpu_ps void @global_store_saddr_i16_d16hi_trunci8_zext_vgpr(i8 addrspace(1)* inreg %sbase, i32 %voffset, <2 x i16> %data) {
; GCN-LABEL: global_store_saddr_i16_d16hi_trunci8_zext_vgpr:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_byte_d16_hi v0, v1, s[2:3]
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %data.hi = extractelement <2 x i16> %data, i32 1
  %data.hi.trunc = trunc i16 %data.hi to i8
  store i8 %data.hi.trunc, i8 addrspace(1)* %gep0
  ret void
}

define amdgpu_ps void @global_store_saddr_i16_d16hi_trunci8_zext_vgpr_offset_neg128(i8 addrspace(1)* inreg %sbase, i32 %voffset, <2 x i16> %data) {
; GCN-LABEL: global_store_saddr_i16_d16hi_trunci8_zext_vgpr_offset_neg128:
; GCN:       ; %bb.0:
; GCN-NEXT:    global_store_byte_d16_hi v0, v1, s[2:3] offset:-128
; GCN-NEXT:    s_endpgm
  %zext.offset = zext i32 %voffset to i64
  %gep0 = getelementptr inbounds i8, i8 addrspace(1)* %sbase, i64 %zext.offset
  %gep1 = getelementptr inbounds i8, i8 addrspace(1)* %gep0, i64 -128
  %data.hi = extractelement <2 x i16> %data, i32 1
  %data.hi.trunc = trunc i16 %data.hi to i8
  store i8 %data.hi.trunc, i8 addrspace(1)* %gep1
  ret void
}