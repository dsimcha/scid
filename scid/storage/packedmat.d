module scid.storage.packedmat;

import scid.matvec;
import scid.storage.packedsubmat;
import scid.storage.packedsubvec;
import scid.internal.assertmessages;
import scid.common.storagetraits;
import scid.ops.common, scid.ops.expression;
import std.algorithm;
import scid.storage.generalmat;

struct PackedStorage( ContainerRef_ ) {
	alias ContainerRef_                                                         ContainerRef;
	alias BaseElementType!ContainerRef                                          ElementType;
	alias storageOrderOf!ContainerRef                                           storageOrder;
	alias PackedSubMatrixStorage!( ContainerRef, SubMatrixType.Slice)           Slice;
	alias PackedSubMatrixStorage!( ContainerRef, SubMatrixType.View)            View;
	alias PackedStorage!( TransposedOf!ContainerRef  )                          Transposed;
	alias Vector!( PackedSubVectorStorage!( ContainerRef, VectorType.Row ) )    RowView;
	alias Vector!( PackedSubVectorStorage!( ContainerRef, VectorType.Column ) ) ColumnView;
	alias ColumnView                                                            DiagonalView;
	alias containerRef_                                                         this;
	
	alias PackedStorage!( ContainerRef.Temporary ) Temporary;
	
	enum isRowMajor   = (storageOrder == StorageOrder.RowMajor );
	
	this(A...)( A args ) {
		containerRef_ = ContainerRef( args );
	}
	
	this( this ) {
		containerRef_ = ContainerRef( containerRef_.ptr );	
	}
	
	void forceRefAssign( ref typeof(this) rhs ) {
		containerRef_ = rhs.containerRef_;
	}
		
	ref typeof(this) opAssign( typeof(this) rhs ) {
		swap( rhs.containerRef_, containerRef_ );
		return this;
	}
	
	RowView row( size_t i )
	in {
		checkSliceIndices_( i, i, 0, columns );
	} body {
		return RowView( containerRef_, i, 0, this.columns );
	}
	
	ColumnView column( size_t j )
	in {
		checkSliceIndices_( 0, rows, j, j );
	} body {
		return ColumnView( containerRef_, j, 0, this.rows );
	}
	
	RowView rowSlice( size_t i, size_t start, size_t end )
	in {
		checkSliceIndices_( i, i, start, end );
	} body {
		return RowView( containerRef_, i, start, end - start );
	}
	
	ColumnView columnSlice( size_t j, size_t start, size_t end )
	in {
		checkSliceIndices_( start, end, j, j );
	} body {
		return ColumnView( containerRef_, j, start, end - start );
	}
	
	View view( size_t rowStart, size_t rowEnd, size_t colStart, size_t colEnd )
	in {
		checkSliceIndices_( rowStart, rowEnd, colStart, colEnd );
	} body {
		return typeof( return )( containerRef_, rowStart, rowEnd - rowStart, colStart, colEnd - colStart );
	}
	
	Slice slice( size_t rowStart, size_t rowEnd, size_t colStart, size_t colEnd )
	in {
		checkSliceIndices_( rowStart, rowEnd, colStart, colEnd );
	} body {
		return typeof( return )( containerRef_, rowStart, rowEnd - rowStart, colStart, colEnd - colStart );
	}
	
	/** Promotions for this type are inherited either from its container or from general matrix. */
	template Promote( Other ) {
		static if( is( Other : typeof(this) ) ) {
			alias typeof(this) Promote;
		} else static if( isScalar!Other ) {
			alias PackedStorage!( Promotion!(Other,ContainerRef) ) Promote;
		} else {
			alias Promotion!( GeneralMatrixStorage!ElementType, Other ) Promote;
		}
	}
	
	@property {
		
		// -- This should be deduced by Matrix now -- //
		//auto front() {
		//	static if( isRowMajor ) return row( 0 );
		//	else                    return column( 0 );
		//}
		//
		//auto back() {
		//	static if( isRowMajor ) return row( this.rows - 1 );
		//	else                    return column( this.columns - 1 );
		//}
		
		// workaround for alias this problems {
		auto size()    const { return containerRef_.size; }
		
		/** Get the size of the array that data/cdata point to. */
		size_t sizeOfData() const {
			return packedArrayLength( size );
		}
		
		alias size rows;
		alias size columns;
		// }
	}
	
	ContainerRef containerRef_;
	
private:
	mixin MatrixChecks;
}

size_t packedArrayLength( size_t matrixSize ) {
	matrixSize *= matrixSize + 1;
	matrixSize >>= 1;
	return matrixSize;
}